
//
// Run isoseq pipeline for PacBio reads
//
include { SAMTOOLS_IMPORT   } from '../../../modules/nf-core/samtools/import/main'   
include { LIMA              } from '../../../modules/nf-core/lima/main' 
include { ISOSEQ3_REFINE    } from '../../../modules/local/isoseq3/refine/main'
include { ISOSEQ3_CLUSTER2   } from '../../../modules/local/isoseq3/cluster2/main'
include { ISOSEQ3_COLLAPSE   } from '../../../modules/local/isoseq3/collapse/main'
include { PBMM2              } from '../../../modules/local/isoseq3/pbmm2/main'

workflow ISOSEQ {
    take:
    ch_samplesheet    // channel: [ val(meta), path(fastq)]
    ch_fasta
    ch_gtf
    
    main:
    ch_versions = Channel.empty()

    //
    // MODULES: SAMTOOLS import in case read is fastq file and not bam
    //
    // ADD conditional check to only convert fastq to bam!!
    SAMTOOLS_IMPORT(
            ch_samplesheet
    )
    ADAPTERS = Channel.value(file("/home/julensan/barcodes.fa", checkIfExists: true))
    LIMA (
       SAMTOOLS_IMPORT.out.bam,
       ADAPTERS // replace with params
    )

    ISOSEQ3_REFINE (
        LIMA.out.bam,
        ADAPTERS // replace with params
    )

    PBMM2 (
        ISOSEQ3_REFINE.out.bam,
        ch_fasta
    )

    ISOSEQ3_COLLAPSE (
        LIMA.out.bam,
        ch_gtf.map { gtf -> [["id": gtf.simpleName], gtf] }
    )
    
    
    emit:
    versions = ch_versions                    // channel: [ path(versions.yml) ]
}





// 3) isoseq refine -j 16 $OUTPUT_PATH/$FQ.lima.bam $PRIMERS  $OUTPUT_PATH/$FQ.refine.bam


// 4) isoseq cluster2 $OUTPUT_PATH/$FQ.refine.bam $OUTPUT_PATH/$FQ.transcripts.bam
 

// echo "Done IsoSeq refine"



// singularity run /home/julensan/tools/pbmm2.sif align --preset ISOSEQ --sort i-G 500k -k 14 $GENOME ${OUTPUT_PATH}/$FQ.transcripts.dedup.bam  ${OUTPUT_PATH}/$FQ.mapped.bam 

// echo "Done IsoSeq pbmm2!"

// singularity run /home/julensan/tools/isoseq.sif collapse ${OUTPUT_PATH}/$FQ.mapped.bam  ${OUTPUT_PATH}/$FQ.gtf

// echo "Done IsoSeq collapse!"