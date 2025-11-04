//
// Run tools for preprocessing of direct RNA and cDNA ONT reads
//

include { SEQKIT_SEQ                  } from '../../../modules/nf-core/seqkit/seq/main'    
include { SEQKIT_STATS               } from '../../../modules/nf-core/seqkit/stats/main'     
include { RESTRANDER                 } from '../../../modules/local/restrander/main'    

workflow ONT_PREPROCESSING {
    take:
    ch_samplesheet    // channel: [ val(meta), path(fastq)]
    

    main:
    ch_versions = Channel.empty()

    //
    // MODULES: Run seqkit_seq
    //
    SEQKIT_SEQ(
        ch_samplesheet
    )

    ch_versions = ch_versions.mix(SEQKIT_SEQ.out.versions.first())

    SEQKIT_STATS(
        SEQKIT_SEQ.out.fastx
    )
    
    ch_restrander_config = Channel.fromPath("${projectDir}/modules/local/restrander/assets/dRNA_ONT.json")
    RESTRANDER (
        SEQKIT_SEQ.out.fastx,
        ch_restrander_config
    )

    emit:
    stats = SEQKIT_STATS.out.stats 
    fastq = RESTRANDER.out.fastq


    versions = ch_versions                    // channel: [ path(versions.yml) ]
}