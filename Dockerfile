FROM rocker/r-ver:4.2.0

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    curl \
    unzip \
    wget \
    gnupg \
    lsb-release \
    libsodium-dev \
    libz-dev

# Install Azure Functions Core Tools using Microsoft's repo
# This is more reliable than downloading the zip file directly
RUN wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y azure-functions-core-tools-4

RUN R -e "install.packages('sys', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('Rcpp', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('rlang', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('later', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('fastmap', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('cli', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('glue', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('askpass', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('R6', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('stringi', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('curl', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('jsonlite', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('webutils', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('magrittr', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('promises', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('httpuv', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('crayon', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('sodium', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('swagger', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('mime', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('lifecycle', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('openssl', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('httr', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('logger', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('plumber', repos='https://cran.rstudio.com/')"


# We'll mount the app directory as a volume instead of copying it
# The directory will be created so it exists even without a mount
RUN mkdir -p /app

# Set up function app configuration
COPY host.json /home/site/wwwroot/
COPY local.settings.json /home/site/wwwroot/

# Install inotify-tools for file watching
RUN apt-get update && apt-get install -y inotify-tools

# Set up a script that restarts the R process when files change
RUN echo '#!/bin/bash\n\
# Start the Azure Functions host in the background\n\
cd /home/site/wwwroot && func host start --verbose &\n\
FUNC_PID=$!\n\
\n\
# Function to start R process\n\
start_r() {\n\
  if [ ! -z "$R_PID" ] && ps -p $R_PID > /dev/null; then\n\
    echo "Stopping previous R process..."\n\
    kill $R_PID\n\
    wait $R_PID 2>/dev/null\n\
  fi\n\
  echo "Starting R process..."\n\
  R -e "source(\"/app/plumber.R\")" &\n\
  R_PID=$!\n\
  echo "R process started with PID: $R_PID"\n\
}\n\
\n\
# Start R initially\n\
start_r\n\
\n\
# Watch for file changes and restart R when detected\n\
while true; do\n\
  inotifywait -e modify,create,delete -r /app\n\
  echo "File change detected, restarting R..."\n\
  start_r\n\
done\n\
' > /start-dev.sh && chmod +x /start-dev.sh

WORKDIR /home/site/wwwroot
EXPOSE 80

# Use the development startup script
CMD ["/start-dev.sh"]