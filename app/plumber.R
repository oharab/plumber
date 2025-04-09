# Load required libraries
library(plumber)
library(logger)

# Configure logging
log_threshold(DEBUG)
log_formatter(formatter_glue)

# # Define API
# api <- plumber::plumber$new()


# Configure host and port
host <- Sys.getenv("PLUMBER_HOST", "0.0.0.0")
port <- as.numeric(Sys.getenv("PLUMBER_PORT", 8080))

# Start the API
log_info("Starting R API server on {host}:{port}")

tryCatch({
  pr("/app/api.R") %>%
    pr_run(host = host, port = port)
}, error = function(e) {
  log_error("Failed to start API server: {e$message}")
  stop(e)
})