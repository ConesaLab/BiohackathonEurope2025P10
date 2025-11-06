#!/usr/bin/env Rscript

################################################
################################################
## REQUIREMENTS                               ##
################################################
################################################

## TRANSCRIPT ISOFORM DISCOVERY AND QUANTIFICATION
    ## - ALIGNED READS IN BAM FILE FORMAT
    ## - GENOME SEQUENCE
    ## - ANNOTATION GTF FILE
    ## - THE PACKAGE BELOW NEEDS TO BE AVAILABLE TO LOAD WHEN RUNNING R

################################################
################################################
## LOAD LIBRARY                               ##
################################################
################################################
library(bambu)
library(GenomeInfoDb)
################################################
################################################
## PARSE COMMAND-LINE PARAMETERS              ##
################################################
################################################
args = commandArgs(trailingOnly=TRUE)

output_tag     <- strsplit(grep('--tag*', args, value = TRUE), split = '=')[[1]][[2]]
ncore          <- strsplit(grep('--ncore*', args, value = TRUE), split = '=')[[1]][[2]]
genomeseq      <- strsplit(grep('--fasta*', args, value = TRUE), split = '=')[[1]][[2]]
genomeSequence <- Rsamtools::FaFile(genomeseq)
Rsamtools::indexFa(genomeseq)
annot_gtf      <- strsplit(grep('--annotation*', args, value = TRUE), split = '=')[[1]][[2]]
flagged_args <- grep('^--', args)
readlist <- args[-flagged_args]

# CRITICAL: Make sure readlist is a proper character vector
cat("\n--- BAM file details ---\n")
cat("readlist class:", class(readlist), "\n")
cat("readlist length:", length(readlist), "\n")
cat("readlist content:", readlist, "\n")
cat("BAM file exists:", file.exists(readlist), "\n")

# Convert to absolute path
readlist <- normalizePath(readlist, mustWork = TRUE)
cat("Normalized path:", readlist, "\n")

# Index BAM if needed
if (!file.exists(paste0(readlist, ".bai"))) {
    cat("Indexing BAM file...\n")
    Rsamtools::indexBam(readlist)
}

cat("\n--- Preparing annotations ---\n")
grlist <- prepareAnnotations(annot_gtf)

cat("\n--- Running bambu ---\n")
# Explicitly create a named list for bambu
readlist_named <- as.list(readlist)
names(readlist_named) <- gsub("\\.bam$", "", basename(readlist))

cat("Named list:", names(readlist_named), "\n")
################################################
################################################
## RUN BAMBU                                  ##
################################################
################################################



# Debug: Check if annotations were loaded
cat("Class of grlist:", class(grlist), "\n")
cat("Length of grlist:", length(grlist), "\n")
if (length(grlist) > 0) {
    cat("First element class:", class(grlist[[1]]), "\n")
} else {
    stop("ERROR: prepareAnnotations returned empty list!")
}



se  <- bambu(reads = readlist, annotations = grlist, genome = genomeSequence, verbose = TRUE, discovery = TRUE, ncore = ncore, quant = FALSE)
#writeBambuOutput(se, output_tag)
writeToGTF(se, "./extended_annotations.gtf")

