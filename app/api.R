library(plumber)
library(jsonlite)
library(logger)

# Source utility functions
source("square.R")

#* Echo back the input
#* @param msg The message to echo
#* @get /api/echo
function(msg = "") {
  log_info("Echo endpoint called with message: {msg}")
  return(list(message = paste0("You said: ", msg)))
}

#* Square a number
#* @param number The number to square
#* @get /api/square
function(number) {
  # Convert to numeric if possible
  num <- as.numeric(number)
  
  # Check if conversion was successful
  if (is.na(num)) {
    log_error("Invalid number provided: {number}")
    res <- list(error = "Please provide a valid number")
    return(res)
  }
  
  log_info("Square endpoint called with number: {num}")
  result <- square_number(num)
  return(list(input = num, result = result))
}

