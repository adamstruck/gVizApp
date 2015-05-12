library(shiny)
library(Gviz)

setwd("~/Projects/ShinyApps/gVizApp/")

## chrom length info
chrInfo <- read.table("hg19_chrInfo.txt",header = TRUE, sep = "\t", stringsAsFactors = FALSE)

## pre-computed Gviz tracks
gtrack <- GenomeAxisTrack()
load("grtrack.RData")
load("itrack.RData")
load("strack.RData")

## list of all genes
load("gene_list.RData")
gene_list <- sort(gene_list)
