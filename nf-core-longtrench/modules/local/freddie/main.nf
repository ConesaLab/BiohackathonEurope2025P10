process FREDDIE {
    tag "${meta.id}"
    label 'process_low'
    
    conda "${moduleDir}/environment.yml"
    container "/home/julensan/tools/freddie.sif"
 

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_freddie*"), emit: gtf    
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args
    def prefix = task.ext.prefix ?: "${meta.id}_freddie"
    def tech_lower = params.technology.toLowerCase().replaceAll(/^dont\$/, 'ont')

    """
    isONclust3 --fastq $reads \\
               --mode $tech_lower \\
               --outfolder $prefix 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        isONclust3: \$( isONclust3 version | sed 's/isONclust3 v//' )
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
