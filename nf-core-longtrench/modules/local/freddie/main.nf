process FREDDIE {
    tag "${meta.id}"
    label 'process_low'
    
    conda "${moduleDir}/environment.yml"
    container "/home/julensan/tools/freddie.sif"
 

    input:
    tuple val(meta), path(reads), path(bam)
    path(license)

    output:
    tuple val(meta), path("*gtf"), emit: gtf    
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args
    def prefix = task.ext.prefix ?: "${meta.id}_freddie"
    def tech_lower = params.technology.toLowerCase().replaceAll(/^dont$/, 'ont')

    """
    freddie_split.py --reads ${reads} \\
                      --bam ${bam} \\
                      --outdir ${prefix}_split \\
                      -t ${task.cpu}

    echo "freddie split completed."

    freddie_segment.py -s  ${prefix}_split \\
                       --outdir  ${prefix}_segment \\
                       -t ${task.cpu}

    echo "freddie segment completed."

    freddie_cluster.py -s ${prefix}_segment \\
                       -o ${prefix}_cluster \\
                       -t ${task.cpu} --timeout 15

    echo "freddie cluster completed."

    freddie_isoforms.py --split-dir  ${prefix}_split \\
                        --cluster-dir ${prefix}_cluster \\
                        --output ${prefix}.gtf" \\
                        -t ${task.cpu}


 
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        freddie: \$(  v0.4' )
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
