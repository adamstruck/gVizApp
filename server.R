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
