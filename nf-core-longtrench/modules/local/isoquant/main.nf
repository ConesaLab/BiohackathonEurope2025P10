process ISOQUANT {
    tag "${meta.id}"
    label 'process_low'
    
    conda "${moduleDir}/environment.yml"
    container "/home/julensan/tools/isoquant.sif"
 

    input:
    tuple val(meta), path(reads)
    tuple val(meta2), path(gtf)
    path(fasta)

    output:
    tuple val(meta), path("*_stringtie.gtf"), emit: gtf
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args
    def prefix = task.ext.prefix ?: "${meta.id}"
    def annotation = gtf ? "--genedb $gtf --complete_genedb" : ''
    def tech_lower = params.technology.toLowerCase().replaceAll(/^dont\$/, 'ont')
    """
    isoquant.py --reference $fasta \\
              ${annotation} \\
              -t $task.cpus \\
              --data_type ${tech_lower} \\
              --bam $reads \\
              --polya_requirement auto --report_canonical all \\
              --output $prefix
           

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        isoquant.py : \$( isoquant.py  --version | sed 's/isoquant v//' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        isoquant.py : \$( isoquant.py  version | sed 's/isoquant v//' )
    END_VERSIONS
    """
}




