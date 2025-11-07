process ISOSEQ3_COLLAPSE {
    tag "$meta.id"
    label 'process_low'

    conda "bioconda::isoseq3=3.8.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/isoseq3:3.8.2--h9ee0642_0' :
        'biocontainers/isoseq3:3.8.2--h9ee0642_0' }"

    input:
    tuple val(meta), path(bam)
    tuple val(meta2), path(gtf)


    output:
    tuple val(meta), path("*.bam")                        , emit: bam
    path  "versions.yml"                                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    isoseq3 \\
        collapse \\
        -j $task.cpus \\
        $args \\
        $bam \\
        $gtf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        isoseq3: \$( isoseq3 refine --version | head -n 1 | sed 's/isoseq refine //' | sed 's/ (commit.\\+//' )
    END_VERSIONS
    """
}