FROM rocker/shiny:4

# Install tools
RUN apt install vim -y

# Install R Base Packages
RUN apt-get -y update && apt-get install -y libudunits2-dev libgdal-dev libgeos-dev libproj-dev

# Install R Packages inside R
RUN R -e "install.packages('devtools', dependences=TRUE)"
RUN R -e "install.packages('plotly', dependences=TRUE)"
RUN R -e "install.packages('forcats', dependences=TRUE)"
RUN R -e "install.packages('data.table, dependences=TRUE')"
RUN R -e "install.packages('dplyr, dependences=TRUE')"
RUN R -e "install.packages('DT, dependences=TRUE')"
RUN R -e "install.packages('heatmaply, dependences=TRUE')"
RUN R -e "install.packages('htmltools, dependences=TRUE')"
RUN R -e "install.packages('leaflet', dependences=TRUE)"
RUN R -e "install.packages('rsconnect', dependences=TRUE)"
RUN R -e "install.packages('sf', dependences=TRUE)"
RUN R -e "install.packages('shiny', dependences=TRUE)"
RUN R -e "install.packages('shinydashboard', dependences=TRUE)"
RUN R -e "install.packages('shinyjs', dependences=TRUE)"
RUN R -e "install.packages('shinythemes', dependences=TRUE)"
RUN R -e "install.packages('shinyBS', dependences=TRUE)"
RUN R -e "install.packages('shinyWidgets', dependences=TRUE)"
RUN R -e "install.packages('tmap', dependences=TRUE)"
RUN R -e "install.packages('rintrojs', dependences=TRUE)"
RUN R -e "install.packages('tmaptools', dependences=TRUE)"
RUN R -e "install.packages('tidyr', dependences=TRUE)"
RUN R -e "install.packages('tidyverse', dependences=TRUE)"
RUN R -e "install.packages('viridisLite', dependences=TRUE)"
RUN R -e "install.packages('ggdark', dependences=TRUE)"
RUN R -e "install.packages('janitor', dependences=TRUE)"
RUN R -e "install.packages('gt', dependences=TRUE)"
RUN R -e "install.packages('fpp3', dependences=TRUE)"
RUN R -e "install.packages('showtext', dependences=TRUE)"

# # Install R Packages inside R from github
RUN R -e "library(devtools); install_github('ramnathv/rCharts')"

# Change user
USER shiny
