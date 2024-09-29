FROM rocker/r-ver

RUN apt-get update && apt-get install -y libssl-dev libcurl4-openssl-dev zlib1g-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libxml2-dev

COPY . shiny
WORKDIR /shiny
RUN R -e "renv::restore()"

EXPOSE 8080

CMD ["R", "-e", "shiny::runApp(appDir='waitz', host='0.0.0.0', port=8080)"]
