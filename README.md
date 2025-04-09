# Simple Plumber API

This is a simple R Plumber API that provides two endpoints:
- `/echo`: Echoes back a message
- `/square`: Squares a number

## Requirements

- R
- plumber package

## Installation

1. Install the required R package:
```R
install.packages("plumber")
```

## Running the API

### Option 1: Running Locally with R

1. Start R and run the following commands:
```R
library(plumber)
pr <- plumb("api.R")
pr$run(port=8000)
```

### Option 2: Running with Docker

1. Build the Docker image:
```bash
docker build -t plumber-api .
```

2. Run the container with local code mounting:
```bash
docker run -p 8000:8000 -v $(pwd):/app plumber-api
```

This mounts your current directory to `/app` in the container, allowing you to make changes to the code without rebuilding the container.

## API Endpoints

### Echo Endpoint
- URL: `http://localhost:8000/echo`
- Method: GET
- Parameter: `msg` (optional)
- Example: `http://localhost:8000/echo?msg=hello`

### Square Endpoint
- URL: `http://localhost:8000/square`
- Method: GET
- Parameter: `x` (required)
- Example: `http://localhost:8000/square?x=5` 