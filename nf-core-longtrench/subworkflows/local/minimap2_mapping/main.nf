//
// Run tools for preprocessing of direct RNA and cDNA ONT reads
//

include { MINIMAP2_ALIGN as MINIMAP2_WO_REF } from '../../../modules/nf-core/minimap2/align/main'
include { MINIMAP2_ALIGN as MINIMAP2_W_REF } from '../../../modules/nf-core/minimap2/align/main'
include { PASSTOOLS_SCORE                 } from '../../../modules/local/2passtools/score/main'

workflow MINIMAP2_MAPPING {
    take:
    ch_samplesheet // channel: [ val(meta), path(fastq)]
    ch_fasta
    ch_gtf

    main:
    ch_versions = Channel.empty()

    //
    // MODULE: Run Minimap2 alignment on genome
    //
    MINIMAP2_WO_REF (
        ch_samplesheet,
        ch_fasta.map { [ [:], it ] },
        true,
        'bai',
        false,
        true
    )
    ch_versions = ch_versions.mix(MINIMAP2_WO_REF.out.versions.first())
    
    //
    // MODULE: Run 2PASSTOOLS MERGE
    //
    PASSTOOLS_SCORE(
        ch_fasta.map { [ [:], it ] },
        MINIMAP2_WO_REF.out.bam

    )

    emit:
    bam = MINIMAP2_WO_REF.out.bam



    versions = ch_versions                    // channel: [ path(versions.yml) ]
}