#!/usr/bin/env Rscript

library(Isosceles)

# Prepare input data
args = commandArgs(trailingOnly=TRUE)

bams <- args[5:length(args)]
gtf <- strsplit(grep('--gtf*', args, value = TRUE), split = '=')[[1]][[2]]
fasta <- strsplit(grep('--fasta*', args, value = TRUE), split = '=')[[1]][[2]]
cpu <- strsplit(grep('--cpu*', args, value = TRUE), split = '=')[[1]][[2]]
outdir <- strsplit(grep('--outdir*', args, value = TRUE), split = '=')[[1]][[2]]

# Run program
bam_files <- c(Sample = bams)
bam_parsed <- bam_to_read_structures(
    bam_files = bam_files
)

transcript_data <- prepare_transcripts(
    gtf_file = gtf,
    genome_fasta_file = fasta,
    bam_parsed = bam_parsed,
    min_bam_splice_read_count = 2,
    min_bam_splice_fraction = 0.01
)

se_tcc <- bam_to_tcc(
    bam_files = bam_files,
    transcript_data = transcript_data,
    run_mode = "de_novo_loose",
    min_read_count = 1,
    min_relative_expression = 0
)
se_tcc

#Create a transcript-level SummarizedExperiment object using the EM algorithm:
se_transcript <- tcc_to_transcript(
    se_tcc = se_tcc,
    use_length_normalization = TRUE
)

#Make the GTF
dir.create(outdir)
export_gtf(se_transcript, file.path(outdir, "transcript_annotation.gtf"))

#'You can export transcript annotations from the SummarizedExperiment object to a GTF file using the export_gtf function'
