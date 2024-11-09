# Use a more recent R version
FROM rocker/r-ver:4.3.2

# Install necessary system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libharfbuzz-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev

# Install R packages required for the enhanced Shiny application
RUN R -e "install.packages(c(\
    'shiny', \
    'dplyr', \
    'ggplot2', \
    'plotly', \
    'tidyr', \
    'readr', \
    'lubridate', \
    'stringr', \
    'bslib', \
    'DT', \
    'sass' \
    ), repos='http://cran.rstudio.com/')"

# Set the working directory
WORKDIR /home/user

# Copy the code to the container
COPY . /home/user

# Expose the Shiny port
EXPOSE 3838

# Command to run the Shiny app
CMD ["R", "-e", "shiny::runApp('/home/user/app.R', host = '0.0.0.0', port = 3838)"]
