process FLAIR {
    tag "${meta.id}"
    label ""

    container "/home/julensan/tools/flair.sif"

    input:
    tuple val(meta), path(reads), path(bedfile)  
    tuple val(meta2), path(gtf)
    path(genome)


    output:
    path "versions.yml", emit: versions
    path "*.fa", emit: fasta
    path "*.gtf", emit: gtf

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}_flair"

    """
    sort -k1,1 -k2,2n -k3,3n ${bedfile} > bedfile.sorted.bed

    awk 'NF == 12 && \$10 != "1" {print \$0}' bedfile.sorted.bed > bedfile.sorted.noMonoexon.bed

    flair collapse  \\
         --query  bedfile.sorted.noMonoexon.bed \\
         -g ${genome} \\
         -f ${gtf} \\
         --read ${reads}
        
    mv flair.collapse.isoforms.gtf ${prefix}.gtf
    mv flair.collapse.isoforms.fa ${prefix}.fa
  
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Flair: \$( flair --version | sed 's/FLAIR //' )
    END_VERSIONS
    """
}