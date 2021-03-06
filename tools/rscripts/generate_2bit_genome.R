#!/usr/bin/env Rscript

# Input arguments: Rscript generate_2bit.R genome outputfile
args <- commandArgs(trailingOnly = TRUE)

if( length(args) > 2 ){
  stop("More than genome and output file name supplied.")
}else if( length(args) < 2 ){
  stop("Please provide inputs as: genome outputfile.")
}

genome <- args[1]
outfile <- args[2]

# Conditional checks
suppressMessages(library(BSgenome))
genName <- grep(genome, unique(installed.genomes()), value = TRUE)

if( length(genName) < 1 ){
  
  stop("No matched BSgenome installed. Please install.")
  
}else if( length(genName) > 1 ){
  
  message("Installed matching genomes:\n")
  message(paste(genName, collapse = ", "))
  stop("Ambiguous match to requested genome. Please specify.")
  
}

if( file.exists(outfile) ) stop("Output file already exists.")

# Load requested genome
suppressMessages(library(genName, character.only = TRUE))
genome <- BiocGenerics::get(genName)

# Check outputfile name
if( !grepl(".2bit$", outfile) ) outfile <- paste0(outfile, ".2bit")

# Write to 2bit output format
BSgenome::export(genome, outfile, format = "2bit")

if( file.exists(outfile) ){
  message("Genome ", genName, " written to 2bit file.")
}else{
  message("Check for output file: ", outfile)
}

q()
