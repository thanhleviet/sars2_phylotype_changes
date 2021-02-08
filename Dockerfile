From openanalytics/r-base AS shiny-base

LABEL maintainer="Thanh Le Viet"
LABEL version="1.0"
LABEL description="Dockerfile for deploying rshiny app"

RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.1 \
    && rm -rf /var/lib/apt/lists/*

# Download and install library
RUN R -e "install.packages(c('shiny', \
                             'shinydashboard', \
                             'shinyWidgets', \
                             'bslib', \
                             'data.table', \
                             'plotly', \
                             'vroom', \
                             'gargle', \
                             'googlesheets4', \
                             'tidyverse'), \
                             repos='https://cloud.r-project.org/')"

FROM shiny-base as sars2
# copy the app to the image
COPY app /app
COPY Rprofile.site /usr/lib/R/etc/

# make all app files readable (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /app
RUN chmod -R 755 /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp(appDir = '/app')"]