library(shiny)
library(Gviz)
# library(TxDb.Hsapiens.UCSC.hg19.knownGene)
# library(BSgenome.Hsapiens.UCSC.hg19)

setwd("~/Projects/ShinyApps/gVizApp/")

# txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene
# grtrack <- GeneRegionTrack(txdb, genome = "hg19",
#                            name = "UCSC known genes")
# itrack <- IdeogramTrack(genome = "hg19")
# strack <- SequenceTrack(Hsapiens)
gtrack <- GenomeAxisTrack()
load("grtrack.RData")
load("itrack.RData")
load("strack.RData")

## Load credentials for login
Logged <- TRUE
load("users.RData")

##--------------------------------------------------------------
## Define the server behavior for the app
##--------------------------------------------------------------
shinyServer(function(input, output) {
	source("www/Login.R",  local = TRUE)
	source("www/appUI.R", local = TRUE)
})
