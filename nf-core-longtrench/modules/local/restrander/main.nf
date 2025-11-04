process RESTRANDER {
    tag "${meta.id}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "/home/julensan/tools/restrander-alpine.sif"
 

    input:
    tuple val(meta), path(reads)
    path(config)

    output:
    tuple val(meta), path("*.fastq.gz"), emit: fastq
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    echo "Module directory: ${moduleDir}"
    ls -la ${moduleDir}/assets/
    restrander \\
        ${reads} \\
        ${prefix}.fastq.gz \\
        ${config}

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




