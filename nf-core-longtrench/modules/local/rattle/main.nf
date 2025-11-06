process RATTLE {
    tag "${meta.id}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "/home/julensan/tools/rattle.sif"
 

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path($prefix), emit: isonclust_gff
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args
    def prefix = task.ext.prefix ?: "${meta.id}"
    def rna_flag = (params.technology == 'dONT') ? '--rna' : ''
  
    """

    rattle cluster -i $reads \\
           -o $prefix \\
           -k 14 --iso \\
           --iso-kmer-size 14 \\
           ${rna_flag}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rattle: \$( rattle version | sed 's/rattle v//' )
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




