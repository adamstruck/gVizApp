##--------------------------------------------------------------
## ui
##--------------------------------------------------------------
output$mainappUI <- renderUI({
	if (USER$Logged == TRUE) {
            fluidPage(
                fluidRow(
                    h2(strong("Gviz Browser"), align = "center"),
                    br()
                    ),
                fluidRow(
                    column(width = 12,
                           wellPanel(title = NULL,
                                     width = NULL,
                                     color = "black",
                                     div(class = "row-fluid", style = "width:100%",
                                         div(style = "display: inline-block; width: 40%; margin: auto 5%; vertical-align: text-top",
                                             textInput(inputId = "coordinates",
                                                       label = "Coordinates: (e.g. chr3:151985829-152183569)",
                                                       value = NULL)),
                                         div(style = "display: inline-block; width: 40%; margin: auto 5%; vertical-align: text-top",
                                             selectizeInput(inputId = "gene_symbol",
                                                            label = "Gene:",
                                                            choices = unique(gene_lookup$symbol),
                                                            selected = "MBNL1",
                                                            multiple = FALSE,
                                                            options = list(maxOptions = 5)
                                                            )),
                                         div(class = "row-fluid", style = "width:100%",
                                             div(style = "display: block; text-align: center",
                                                 actionButton(inputId = "submit",
                                                              label = "Update View")
                                                 )
                                             )
                                         )
                                     )
                           )
                    ),
                fluidRow(
                    column(width = 3,
                           wellPanel(
                               fileInput(inputId = 'file1',
                                         label = 'Choose CSV File',
                                         accept = c('text/csv',
                                             'text/comma-separated-values,text/plain',
                                             '.csv')
                                         ),
                               tags$hr(),
                               checkboxInput(inputId = 'header',
                                             label = 'Header',
                                             value = TRUE),
                               radioButtons(inputId = 'sep',
                                            label = 'Separator',
                                            choices = c(Comma=',',
                                                Semicolon=';',
                                                Tab='\t'),
                                            selected = ','),
                               radioButtons(inputId = 'quote',
                                            label = 'Quote',
                                            choices = c(None='',
                                                'Double Quote'='"',
                                                'Single Quote'="'"),
                                            selected = '"')
                               )
                           ),
                    column(width = 9,
                           plotOutput(outputId = "plot")
                           )
                    )
                )
	}
})

##--------------------------------------------------------------
## server
##--------------------------------------------------------------
coordinates <- reactive({
    if (is.null(input$coordinates) || input$coordinates == "") {
        ""
    } else {
        coords <- unlist(lapply(strsplit(input$coordinates, "[:-]| +"), function(x) { x[x != ""] }))
    }
    if (length(coords) == 3 && as.numeric(coords[2]) < as.numeric(coords[3])) {
        coordinates <- c(as.character(coords[1]), as.numeric(coords[2]), as.numeric(coords[3]))
        coordinates
    } else {
        ""
    }
})

gene_info <- reactive({
    coords <- coordinates()
    if (input$gene_symbol != "") {
        gene_filter <- interp(~ param == input$gene_symbol, param = as.name("symbol"))
        gene_info <- filter_(gene_lookup, .dots = gene_filter)
    } else if (coords[1] != "") {
        coords_granges <- GRanges(seqnames = coords[1], ranges = IRanges(as.numeric(coords[2]), as.numeric(coords[3])))
        hits <- findOverlaps(coords_granges, gene_lookup_granges)
        gene_info <- gene_lookup_granges[subjectHits(hits),] %>% as.data.frame()
        names(gene_info)[c(1,4)] <- c("chr", "length")
    } else {
        gene_info <- ""
    }
    gene_info
})


##
## Read in user supplied data
##
output$contents <- renderTable({
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    inFile <- input$file1

    if (is.null(inFile)) {
        return(NULL)
    }
          
    read.csv(inFile$datapath, header=input$header, sep=input$sep,
             quote=input$quote)
})


##
## Output gene & event info
##
output$gene_summary <- renderUI({
    input$submit
    isolate({
        gene_info <- gene_info()
        if (gene_info[[1]][1] == "") {
            HTML("<br/>")
        } else if (length(unique(gene_info$symbol)) == 1) {
            header <- strong(gene_info$symbol[1])
            loc <- paste(paste(gene_info$chr[1], min(gene_info$start), sep = ": "), max(gene_info$end), sep = " - ")
            strand <- paste("Strand: ", gene_info$strand[1])
            desc <- em(gene_info$description[1])
            entrez <- paste("Entrez ID:  ", paste(unique(gene_info$entrez), collapse = ", "))
            ensembl <- paste("Ensembl ID:  ", paste(unique(gene_info$ensembl), collapse = ", "))
            HTML(paste(header, loc, strand, desc, entrez, ensembl,  sep = "<br/>"))
        } else {
            HTML(strong("Mutliple genes interect the coordinates provided"))
        }
    })
})

##
## Plot gene models
##
output$gene_model <- renderPlot({
    input$submit
    ## Gene info takes into account coordinates
    isolate({
        gene_info <- gene_info()
        coords <- coordinates()
        if (coords[1] != "") {
            chr <- coords[1]
            start <- as.numeric(coords[2])
            end <- as.numeric(coords[3])
        } else if (gene_info[[1]][1] != "") {
            chr <- gene_info$chr[1]
            start <- min(gene_info$start)
            end <- max(gene_info$end)
        } else {
            ## Prevent from plotting
            start <- 10
            end <- 1
        }
        if (start < end) {
            ## Switch active chromosome
            chromosome(itrack) <- chr
            chromosome(gtrack) <- chr
            chromosome(grtrack) <- chr
            if (is.null(output$contents)) {
                tracks <- c(itrack, gtrack, grtrack)
            } else {
                ## Data track
                dtrack <- NULL                
                tracks <- c(itrack, gtrack, dtrack, grtrack)
            }
            ## Plot all tracks
            plot_main <- plotTracks(trackList = tracks,
                                    from = start, to = end)            
            print(plot_main)
        }
    })
})
