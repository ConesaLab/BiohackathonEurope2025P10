process PBMM2 {
    tag "$meta.id"
    label 'process_low'

    conda "bioconda::isoseq3=3.8.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/isoseq3:3.8.2--h9ee0642_0' :
        'biocontainers/isoseq3:3.8.2--h9ee0642_0' }"

    input:
    tuple val(meta), path(bam)
    path(fasta)


    output:
    tuple val(meta), path("*_mapped.bam")                        , emit: bam

    path  "versions.yml"                                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    pbmm2 align --preset ISOSEQ \\
                --sort i-G 500k -k 14 \\
                $fasta $bam ${prefix}_mapped.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pbmm2: \$( pbmm2 --version | head -n 1 | sed 's/isoseq refine //' | sed 's/ (commit.\\+//' )
    END_VERSIONS
    """
}