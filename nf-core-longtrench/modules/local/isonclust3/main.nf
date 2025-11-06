process ISONCLUST3 {
    tag "${meta.id}"
    label 'process_low'
    
    conda "${moduleDir}/environment.yml"
    container "/home/julensan/tools/isONclust.sif"
 

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*/clustering/final_clusters.tsv"), emit: isonclust_gff
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args
    def prefix = task.ext.prefix ?: "${meta.id}"
    def tech_lower = params.technology.toLowerCase().replaceAll(/^dont$/, 'ont')

    """
    # Unzip reads if gzipped
    if [[ ${reads} == *.gz ]]; then
        gunzip -c ${reads} > reads_decompressed.fastq
        READS="reads_decompressed.fastq"
    else
        READS="${reads}"
    fi

    isONclust3 --fastq \$READS \\
           --mode ${tech_lower} \\
           --outfolder ${prefix}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        isONclust3: \$( isONclust3 --version | sed 's/isONclust3 v//' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        isONclust3: \$( isONclust3 version | sed 's/isONclust3 v//' )
    END_VERSIONS
    """
}




