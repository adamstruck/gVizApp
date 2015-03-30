library(shiny)
library(Gviz)
# library(TxDb.Hsapiens.UCSC.hg19.knownGene)
# library(BSgenome.Hsapiens.UCSC.hg19)

setwd("~/Projects/ShinyApps/gVizApp/")

## chrom length info
chrInfo <- read.table("hg19_chrInfo.txt",header = TRUE, sep = "\t", stringsAsFactors = FALSE)

## create sample list
pdata <- read.table("DM_sample_pdata.txt",header = TRUE, sep = "\t", stringsAsFactors = FALSE)
pdata <- setNames(pdata, c("sample", "diagnosis", "tissue", "group", "read_length"))
samples <- pdata$sample

## list of all genes
load("gene_list.RData")
gene_list <- sort(gene_list)

##--------------------------------------------------------------
## Define the basic UI containers
##--------------------------------------------------------------
shinyUI(
	bootstrapPage(
		tagList(
			tags$head(
				tags$link(rel="stylesheet", type="text/css",href="style.css"),
				tags$script(type="text/javascript", src = "md5.js"),
				tags$script(type="text/javascript", src = "passwdInputBinding.js")
			)
		),

		div(class = "login",
				uiOutput("uiLogin"),
				textOutput("pass")
		),

		div(class = "output",
				uiOutput("mainappUI"))

	))
