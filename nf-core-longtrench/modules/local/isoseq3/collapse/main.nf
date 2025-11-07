process ISOSEQ3_COLLAPSE {
    tag "$meta.id"
    label 'process_low'

    conda "bioconda::isoseq3=3.8.2"
    container "/home/julensan/tools/isoseq.sif"

    input:
    tuple val(meta), path(bam)


    output:
    tuple val(meta), path("*.gff")                        , emit: gtf
    path  "versions.yml"                                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}_isoseq3"
    """
    isoseq \\
        collapse \\
        -j $task.cpus \\
        $args \\
        $bam \\
        ${prefix}.gff

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        isoseq3: \$( isoseq --version | head -n 1 | sed 's/isoseq refine //' | sed 's/ (commit.\\+//' )
    END_VERSIONS
    """
}