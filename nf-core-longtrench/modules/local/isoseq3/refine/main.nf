process ISOSEQ3_REFINE {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::isoseq3=3.8.2"
    container "/home/julensan/tools/isoseq.sif"

    input:
    tuple val(meta), path(bam)
    path primers

    output:
    tuple val(meta), path("*.bam")                        , emit: bam
    tuple val(meta), path("*.bam.pbi")                    , emit: pbi
    tuple val(meta), path("*.consensusreadset.xml")       , emit: consensusreadset
    tuple val(meta), path("*.filter_summary.report.json") , emit: summary
    tuple val(meta), path("*.report.csv")                 , emit: report
    path  "versions.yml"                                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}_isoseq_refine"
    """
    isoseq \\
        refine \\
        -j $task.cpus \\
        $args \\
        $bam \\
        $primers \\
        ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        isoseq3: \$( isoseq3 refine --version | head -n 1 | sed 's/isoseq refine //' | sed 's/ (commit.\\+//' )
    END_VERSIONS
    """
}