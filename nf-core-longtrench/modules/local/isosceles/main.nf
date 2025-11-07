process ISOSCELES {
    label 'process_short'

    container "/home/julensan/tools/isosceles.sif"

    input:
    path(fasta)
    tuple val(meta), path(gtf)
    tuple val(meta2), path(bams)

    output:
    path "*.gtf"                   , emit: gtf
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args
    def prefix = task.ext.prefix ?: "${meta.id}_isosceles"
    """
     mkdir -p $prefix
     run_isosceles.r \\
        --gtf=$gtf \\
        --fasta=$fasta \\
        --cpu=${task.cpus} \\
        --outdir=$prefix \
        $bams


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        Isosceles: \$(Rscript -e "library(Isosceles); cat(as.character(packageVersion('Isosceles')))")
    END_VERSIONS
    """
}
