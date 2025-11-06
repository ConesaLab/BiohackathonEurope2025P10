process FLAIR {
    tag "${meta.id}"
    label ""

    container "/home/julen/san/tools/flair.sif"

    input:
    tuple val(meta),  path(bedfile)
    tuple val(meta2), path(gtf)
    tuple val(meta3), path(genome)
    tuple val(meta4), path(reads)


    output:
    path "versions.yml", emit: versions
    path "flair.collapse_all.isoform.counts.txt"
    path "flair.collapse_all.isoform.isoforms.bed"
    path "flair.collapse_all.isoform.isoforms.fa"
    path "flair.collapse_all.isoform.isoforms.gtf"

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """

    sort -k1,1 -k2,2n -k3,3n ${bedfile} > bedfile.sorted.bed

    awk 'NF == 12 && \$10 != "1" {print \$0}' bedfile.sorted.bed > bedfile.sorted.noMonoexon.bed

    flair collapse --query  bedfile.sorted.noMonoexon.bed -g ${genome} -f ${gtf} --read ${fastq}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Flair: \$( flair --version | sed 's/FLAIR //' )
    END_VERSIONS
    """

}