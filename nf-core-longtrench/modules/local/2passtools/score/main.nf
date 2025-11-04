process PASSTOOLS_SCORE {
    tag "${meta.id}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "/home/julensan/tools/2passtool.sif"
 

    input:
    tuple val(meta), path(genome)
    tuple val(meta2), path(bam), path(bai)


    output:
    tuple val(meta), path("*.fastq.gz"), emit: fastq
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args
    def prefix = task.ext.prefix ?: "${meta2.id}"

    """
    2passtools score --ref-fasta-fn $genome \\
        -p ${task.cpus} \\
        -m "GTAG|GCAG|ATAG|ATAC" \\
        --classifier-type random_forest \\
        -o ${prefix}.bed \\
        ${bam}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        restrander: \$( restrander version | sed 's/restrander v//' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        restrander: \$( restrander version | sed 's/restrander v//' )
    END_VERSIONS
    """
}




