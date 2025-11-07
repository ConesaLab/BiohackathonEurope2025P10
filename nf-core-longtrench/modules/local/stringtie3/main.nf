process STRINGTIE3 {
    tag "${meta.id}"
    label 'process_low'
    
    conda "${moduleDir}/environment.yml"
    container "/home/julensan/tools/stringtie3.sif"
 

    input:
    tuple val(meta), path(reads)
    tuple val(meta2), path(gtf)

    output:
    tuple val(meta), path("*_stringtie.gtf"), emit: gtf
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args
    def prefix = task.ext.prefix ?: "${meta.id}"
    def annotation = gtf ? "-G ${gtf}" : ''

    """
    stringtie -L \\
              -o ${prefix}_stringtie.gtf \\
              -p $task.cpus \\
              ${annotation} \\
              $reads \\


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        stringtie: \$( stringtie --version | sed 's/stringtie v//' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        stringtie: \$( stringtie version | sed 's/stringtie v//' )
    END_VERSIONS
    """
}




