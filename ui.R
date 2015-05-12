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
            uiOutput("mainappUI")
            )        
	)
    )
