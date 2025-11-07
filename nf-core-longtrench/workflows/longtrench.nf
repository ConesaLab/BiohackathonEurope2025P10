/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { FASTQC                 } from '../modules/nf-core/fastqc/main'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_longtrench_pipeline'
include { ONT_PREPROCESSING      } from '../subworkflows/local/ont_preprocessing/main'
include { MINIMAP2_MAPPING        } from '../subworkflows/local/minimap2_mapping/main'
include { ISOSEQ                 } from '../subworkflows/local/isoseq/main'
include { BAMBU                    } from '../modules/local/bambu/main'
include { ISONCLUST3                } from '../modules/local/isonclust3'
include { RATTLE                   } from '../modules/local/rattle/main'
include { STRINGTIE3 as STRINGTIE3_W_REF } from  '../modules/local/stringtie3/main'
include { STRINGTIE3 as STRINGTIE3_WO_REF } from  '../modules/local/stringtie3/main'
include { ISOQUANT as ISOQUANT_W_REF  } from   '../modules/local/isoquant/main'
include { ISOQUANT as ISOQUANT_WO_REF  } from   '../modules/local/isoquant/main'
include { ESPRESSO                } from    '../modules/local/espresso/main'
include { BEDTOOLS_BAMTOBED       } from '../modules/nf-core/bedtools/bamtobed/main' 
include { FLAIR                   } from '../modules/local/flair/main'
include { FREDDIE                 } from '../modules/local/freddie/main'
include { ISOSCELES               } from '../modules/local/isosceles/main'
include { SEQKIT_FQ2FA            } from '../modules/nf-core/seqkit/fq2fa/main'  
include { SAMTOOLS_INDEX } from '../modules/nf-core/samtools/index/main'  
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow LONGTRENCH {

    take:
    ch_samplesheet 
    reads       
    gtf         // channel: path(genome.gtf)

    main:

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()
     

    ch_fasta    = Channel.value(file(reads, checkIfExists: true))
    ch_samplesheet.view()

    //
    // Uncompress GTF annotation file # TODO: add gff option
    //
    if (gtf.endsWith('.gz')) {
                ch_gtf      = GUNZIP_GTF ( [ [:], file(gtf, checkIfExists: true) ] ).gunzip.map { it[1] }
                ch_versions = ch_versions.mix(GUNZIP_GTF.out.versions)
            } else {
                ch_gtf = Channel.value(file(gtf, checkIfExists: true))
    }
    //
    // MODULE: Run FastQC
    //
    FASTQC (
        ch_samplesheet
    )
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]})
    ch_versions = ch_versions.mix(FASTQC.out.versions.first())
    //
    // SUBWORFLOW: Read preprocessing of ONT reads
    //
    if (params.technology == 'ONT' || params.technology == 'dONT') {
       ONT_PREPROCESSING(ch_samplesheet)
    }

    ch_samplesheet_processed = (params.technology == 'ONT' || params.technology == 'dONT') ? 
         ONT_PREPROCESSING.out.fastq : 
         ch_samplesheet
    

    // ------ Running genome free tools ----------


    //
    // MODULE: Run IsonClust3
    //
    ISONCLUST3(
        ch_samplesheet_processed
    )
    ch_versions = ch_versions.mix(ISONCLUST3.out.versions.first())
    
    // MODULE: Run rattle on fastq
    //
    RATTLE(
        ch_samplesheet_processed
    )

    //
    // Convert fastq from rattle to fast
    //
    SEQKIT_FQ2FA(
        RATTLE.out.fastq
    )
    ch_versions = ch_versions.mix(SEQKIT_FQ2FA.out.versions.first())

    //
    // SUBWORKFLOW: Run minimap2 
    //
    MINIMAP2_MAPPING (
        ch_samplesheet_processed,
        ch_fasta,
        ch_gtf
    )
    ch_versions = ch_versions.mix(MINIMAP2_MAPPING.out.versions.first())

    if (params.technology == 'PacBio') {
       ISOSEQ(
         ch_samplesheet,
         ch_fasta
        )
    }

       

    // ------ Running reference based tools ----------

    // 
    // MODULE: Run BAMBU
    //
    BAMBU (
        ch_fasta,
        ch_gtf.map { gtf -> [["id": gtf.simpleName], gtf] },
        MINIMAP2_MAPPING.out.bam_wo_ref
    )
    ch_versions = ch_versions.mix(BAMBU.out.versions.first())
    //
    // MODULE: Run espresso
    //
    ESPRESSO (
        MINIMAP2_MAPPING.out.bam_wo_ref,
        ch_gtf.map { gtf -> [["id": gtf.simpleName], gtf] },
        ch_fasta
    )
    ch_versions = ch_versions.mix(ESPRESSO.out.versions.first())
    //
    // MODULES: BEDTOOLS_BAMTOBED
    //
    BEDTOOLS_BAMTOBED(
        MINIMAP2_MAPPING.out.bam_wo_ref
    )
    // 
    // MODULE: Run ISOSCELES
    //
    ISOSCELES (
        ch_fasta,
        ch_gtf.map { gtf -> [["id": gtf.simpleName], gtf] },
        MINIMAP2_MAPPING.out.bam_wo_ref
    )
    ch_versions = ch_versions.mix(ISOSCELES.out.versions.first())
    
    // MODULE: FLAIR
    //
    FLAIR (
        // fastq
        ch_samplesheet_processed.combine(BEDTOOLS_BAMTOBED.out.bed, by: 0),
        // GTF
        ch_gtf.map { gtf -> [["id": gtf.simpleName], gtf] },
        // genome.fa
        ch_fasta
    )
    ch_versions = ch_versions.mix(FLAIR.out.versions.first())
    
    //
    // MODULE: Run freddie
    //

    ch_freddie_license = Channel.fromPath("${HOME}/gurobi.lic")
    FREDDIE(
       ch_samplesheet_processed.combine(MINIMAP2_MAPPING.out.bam_wo_ref, by: 0).combine(MINIMAP2_MAPPING.out.index_wo_ref, by: 0),
       ch_freddie_license
    )
    ch_versions = ch_versions.mix(FREDDIE.out.versions.first())

    // ------ Running tools that can be run without reference ----------
    //
    // MODULE: Run Stringtie3 with and without annotation
    //
    // with annotation
    STRINGTIE3_W_REF (
        MINIMAP2_MAPPING.out.bam_wo_ref,
        ch_gtf.map { gtf -> [["id": gtf.simpleName], gtf] }
    )
    // without annotation
    STRINGTIE3_WO_REF (
        MINIMAP2_MAPPING.out.bam_wo_ref,
        Channel.value([[:], []])
    )
    ch_versions = ch_versions.mix(STRINGTIE3_WO_REF.out.versions.first())

    //
    // MODULE: Run IsoQuant
    //
    // with reference
    ISOQUANT_W_REF(
        MINIMAP2_MAPPING.out.bam_wo_ref,
        MINIMAP2_MAPPING.out.index_wo_ref,
        ch_gtf.map { gtf -> [["id": gtf.simpleName], gtf] },
        ch_fasta
    )
    // without reference
    ISOQUANT_WO_REF(
        MINIMAP2_MAPPING.out.bam_wo_ref,
        MINIMAP2_MAPPING.out.index_wo_ref,
        Channel.value([[:], []]),
        ch_fasta
    )
    ch_versions = ch_versions.mix(ISOQUANT_WO_REF.out.versions.first())
    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  +  'longtrench_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }
    

    //
    // MODULE: MultiQC
    //
    ch_multiqc_config        = Channel.fromPath(
        "$projectDir/assets/multiqc_config.yml", checkIfExists: true)
    ch_multiqc_custom_config = params.multiqc_config ?
        Channel.fromPath(params.multiqc_config, checkIfExists: true) :
        Channel.empty()
    ch_multiqc_logo          = params.multiqc_logo ?
        Channel.fromPath(params.multiqc_logo, checkIfExists: true) :
        Channel.empty()

    summary_params      = paramsSummaryMap(
        workflow, parameters_schema: "nextflow_schema.json")
    ch_workflow_summary = Channel.value(paramsSummaryMultiqc(summary_params))
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
        file(params.multiqc_methods_description, checkIfExists: true) :
        file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    ch_methods_description                = Channel.value(
        methodsDescriptionText(ch_multiqc_custom_methods_description))

    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_methods_description.collectFile(
            name: 'methods_description_mqc.yaml',
            sort: true
        )
    )

    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList(),
        [],
        []
    )

    emit:multiqc_report = MULTIQC.out.report.toList() // channel: /path/to/multiqc_report.html
    versions       = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
