FROM rocker/shiny:4

# Change user
USER shiny

# Install tools
RUN apt install vim -y

# Install R Base Packages
RUN apt-get -y update && apt-get install -y libudunits2-dev libgdal-dev libgeos-dev libproj-dev

# Install R Packages inside R
RUN R -e "install.packages('devtools')"
RUN R -e "install.packages('plotly')"
RUN R -e "install.packages('forcats')"
RUN R -e "install.packages('data.table')"
RUN R -e "install.packages('dplyr')"
RUN R -e "install.packages('DT')"
RUN R -e "install.packages('heatmaply')"
RUN R -e "install.packages('htmltools')"
RUN R -e "install.packages('leaflet')"
RUN R -e "install.packages('rsconnect')"
RUN R -e "install.packages('sf')"
RUN R -e "install.packages('shinydashboard')"
RUN R -e "install.packages('shinyjs')"
RUN R -e "install.packages('shinythemes')"
RUN R -e "install.packages('shinyBS')"
RUN R -e "install.packages('shinyWidgets')"
RUN R -e "install.packages('tmap')"
RUN R -e "install.packages('rintrojs')"
RUN R -e "install.packages('tmaptools')"
RUN R -e "install.packages('tidyr')"
RUN R -e "install.packages('tidyverse')"
RUN R -e "install.packages('viridisLite')"
RUN R -e "install.packages('ggdark')"
RUN R -e "install.packages('janitor')"

# # Install R Packages inside R from github
RUN R -e "library(devtools); install_github('ramnathv/rCharts')"