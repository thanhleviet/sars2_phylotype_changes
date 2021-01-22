From openanalytics/r-base

RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.1

# Download and install library
RUN R -e "install.packages(c('shiny','shinydashboard', 'data.table', 'plotly', 'gargle', 'googlesheets4','tidyverse'), repos='https://cloud.r-project.org/')"

# copy the app to the image
COPY app /root/app
COPY Rprofile.site /usr/lib/R/etc/

# make all app files readable (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /root/app
RUN chmod -R 755 /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp(appDir = '/root/app')"]