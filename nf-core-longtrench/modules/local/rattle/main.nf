process RATTLE {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "/home/julensan/tools/rattle.sif"
 
    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('*.fq'), emit: fastq
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args
    def prefix = task.ext.prefix ?: "${meta.id}_rattle"
    def rna_flag = (params.technology == 'dONT') ? '--rna' : ''
  
    """
    mkdir -p $prefix

    rattle cluster -i $reads \\
           -o $prefix \\
           -k 14 --iso \\
           --iso-kmer-size 14 \\
           ${rna_flag}

    rattle correct -i  *.fastq \\
          -c $prefix/clusters.out \\
          -o $prefix 
    
    rattle polish -i $prefix/consensi.fq \\
                  -o $prefix \\
                  ${rna_flag}
    
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rattle: 1.0
    END_VERSIONS

    mv */*transcriptome.fq ${prefix}.fq
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rattle: \$( rattle --version | sed 's/rattle v//' )
    END_VERSIONS
    """
}




