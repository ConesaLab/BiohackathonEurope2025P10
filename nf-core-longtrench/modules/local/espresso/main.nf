process ESPRESSO {
    tag "${meta.id}"
    label 'process_low'
    
    conda "${moduleDir}/environment.yml"
    container "/home/julensan/tools/espresso_1.6.0--9eb8d902e8f7c23f.sif"
 
    input:
    tuple val(meta), path(bam)
    tuple val(meta2), path(gtf)
    path(fasta)

    output:
    tuple val(meta), path("*/*.gtf"), emit: gtf
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args
    def prefix = task.ext.prefix ?: "${meta.id}_espresso"
    def annotation = gtf ? "-A $gtf" : ''
    """
    # make sample.tsv for current sample


    printf "${bam}\\t${meta.id}\\n" > sample.tsv	
    echo "Running ESPRESSO_S.pl..."
    perl /opt/conda/bin/ESPRESSO_S.pl \\
        -L sample.tsv \\
        -F $fasta \\
        $annotation \\
        -O $prefix \\
        -T $task.cpus

    echo "Running ESPRESSO_C.pl..."
    perl /opt/conda/bin/ESPRESSO_C.pl \\
        -I $prefix  \\
        -F  $fasta \\
        -X 0 \\
        -T $task.cpus \\
        $annotation 
        

    echo "Running ESPRESSO_Q.pl..."
    perl /opt/conda/bin/ESPRESSO_Q.pl \\
         -L $prefix/sample.tsv.updated 


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        espresso: \$(1.6)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        espresso: \$(1.6)
    END_VERSIONS
    """
}




