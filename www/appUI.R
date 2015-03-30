##--------------------------------------------------------------
## ui
##--------------------------------------------------------------
output$mainappUI <- renderUI({
	if (USER$Logged == TRUE) {
            fluidPage(
                titlePanel(NULL),
                sidebarLayout(
                    sidebarPanel(
                        selectInput(inputId = "samples",
                                    label = "Samples:",
                                    choices = samples,
                                    selected = samples[1],
                                    selectize = TRUE,
                                    multiple = TRUE),
                        ## selectInput(inputId = "gene_symbol",
                        ##             label = "Gene:",
                        ##             choices = gene_list,
                        ##             selectize = TRUE,
                        ##             multiple = FALSE),
                        selectInput(inputId = "chr",
                                    label = "Chr:",
                                    choices = chrInfo$chr,
                                    selected = chrInfo$chr[1],
                                    selectize = TRUE,
                                    multiple = FALSE),
                        numericInput(inputId = "start",
                                     label = "Position Start",
                                     value = 10000,
                                     min = 1,
                                     # max = chrInfo[chrInfo$chr == input$chr, "length"]),
                                     max = NA),
                        numericInput(inputId = "end",
                                     label = "Position End",
                                     value = 16000,
                                     min = 1,
                                     # max = chrInfo[chrInfo$chr == input$chr, "length"]
                                     max = NA),
                        width = 2
                    ),
                    mainPanel(
                        plotOutput(outputId = "plot")
                    )
                )
            )
	}
    })

##--------------------------------------------------------------
## server
##--------------------------------------------------------------
output$plot <- renderPlot({
    samples <- input$samples
    chr <- input$chr
    start <- input$start
    end <- input$end

    if (start < end) {
        files <- sapply(samples, function(x) paste("~/aciss_mount_point/wiggle_files/DMseq_allsamples/", x, ".bw", sep = ""))
        for (i in 1:length(files)) {
            file <- files[i]
            assign(paste("ctrack", i, sep = ""), 
                   DataTrack(range = file, genome = "hg19", type = "l",
                             name = samples[i], window = -1, chromosome = chr),
                   )
        }
        tracks <- c(itrack, gtrack, strack, grtrack, mget(ls(pattern = "ctrack")))
        plot_main <- plotTracks(trackList = tracks, chromosome = chr,
                                from = start, to = end, showId = TRUE)
        print(plot_main)
    }
})
