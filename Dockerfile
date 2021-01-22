From rocker/tidyverse:4.0.0-ubuntu18.04

RUN apt-get update && apt-get install libcurl4-openssl-dev libv8-3.14-dev -y &&\
    mkdir -p /var/lib/shiny-server/bookmarks/shiny

# Download and install library
RUN R -e "install.packages(c('shiny','shinydashboard', 'data.table', 'plotly', 'gargle', 'googlesheets4'), repos='https://cloud.r-project.org/')"

# copy the app to the image
COPY app /root/app
COPY Rprofile.site /usr/local/lib/R/etc/Rprofile.site

# make all app files readable (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /root/app
RUN chmod -R 755 /usr/local/lib/R/etc

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp(appDir = '/root/app', host = '127.0.0.1', port=3838)"]