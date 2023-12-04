#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

suppressPackageStartupMessages({
    library(rsconnect)
    library(ggstream)
    library(shiny)
    library(shinythemes)
    library(shinyBS)
    library(shinyWidgets)
    library(shinydashboard)
    library(tidyverse)
    library(plotly)
    library(sf)
    library(tmap)
    library(rintrojs)
    library(heatmaply)
    library(ggplot2)
    library(tmaptools)
    library(classInt)
    library(shinyjs)
    library(lwgeom)
    library(rsconnect)
    library(shiny)
   #library(rCharts)
    library(tidyverse)
    library(plotly)
    library(sf)
    library(leaflet)
    library(shinyjs)
    library(classInt)
    library(ggplot2)
    library(ggmap)
    library(mapview)
    library(leafpop)
    
})



# setwd('vetor_app/')
# data ------------------------------------------------------------
suppressMessages({
    municipios <- st_read('municipios_limite.gpkg', as_tibble = T, quiet = T)
    vetores <- read.csv("Dados Vetores.csv", dec = ',', sep = ";", encoding = "ISO-8859-1")
    
    vetores <- vetores %>% 
      mutate(
        Species = gsub("\u00A0", " ", Species, fixed = TRUE), # Non breaking space
        Species = gsub("\\s{2,5}", " ", Species), # Multiple whitespaces
        Species = trimws(Species),
        Infection = factor(Infection, c("Sim", "Não", ""), c("Sim", "Não", "NA"))) %>%
      select(ID, codigo, Species,Municipality,State,Collection_data_start,Collection_data_end,
             Location,Latitude,Longitude,Reference,Publication.Year, Infection) %>% 
      distinct()
    
    vetores %>% pull(Species) %>% unique() %>% sort()
    
    desmatamento <- read.csv("df_floresta.csv", dec = ",", sep = ";", na.strings = "nada consta")
    
    desmatamento <- unique(desmatamento)
})


species_select <-  vetores %>% pull(Species) %>% unique() %>% sort()
infection_select <-  vetores %>% pull(Infection) %>% unique() %>% sort()

# munge -----------------------------------------------------------------------
# general
munic_names <- municipios %>%
    st_drop_geometry() %>%
    select(code_muni, name_muni)

# spatial
municipios2 <- municipios %>%
    st_make_valid() %>%
    filter(code_state %in% c(11:17, 21, 51)) %>%
    select(code = code_muni, name = name_muni) %>%
    mutate(cod6 = as.integer(substr(code, 1, 6))) %>%
    select(-code) %>%
    st_transform(crs = 4326)

base_bb <- st_sf(a = 1:2,
                 geom = st_sfc(
                     st_point(c(-1212183.85, 7945639.07)),
                     st_point(c(1850099.70, 10557683.96))),
                 crs = 4326)

server <- shinyServer(function(input, output, session) {
    
  # base map ------------------------------------------------------------------
  factPal <- colorFactor(palette = "inferno", levels = infection_select, ordered = FALSE)
  # --------------------------------------------------- Server -----------------------------------------------------------------------
  output$map <- renderLeaflet({
    basemap <-
      municipios2 %>%
      st_make_valid()
    
    leaflet(basemap,options = leafletOptions(minZoom = 5, maxZoom = 18)) %>%
      addProviderTiles(provider = "OpenStreetMap.Mapnik") %>%
      fitBounds(-75, -18, -46, 5) %>%
      addCircleMarkers(data = vetores, lng = ~Longitude, lat = ~Latitude, layerId=~codigo,
                       color = factPal(~Infection), radius = 2, fillOpacity = 1,
                       popup = paste("ID", ~ID, "<br>",
                                     "Espécie:",  ~Species, "<br>",
                                     "Referência:", ~Reference, "<br>",
                                     "Ano de publicação:", ~Publication.Year, "<br>",
                                     "Data de inicio da coleta:", ~Collection_data_start, "<br>",
                                     "Data final da coleta:", ~Collection_data_end,"<br>",
                                     "Estado:", ~State, "<br>",
                                     "Município:", ~Municipality,"<br>",
                                     "Localização:", ~Location, "<br>")) %>%  
      addLegend(position = "bottomright", title = "Detecção de <i>Plasmodium sp</i>", data = vetores,
                pal = factPal, values = ~Infection)
  })
  
  
  observeEvent(input$filter, { 
    updateSelectizeInput(session,"species_filter", 
                         label = NULL,
                         choices = species_select, 
                         selected = character(0), 
                         options = list(
                           maxOptions = 1000,
                           placeholder = "Digite para procurar a espécie"))
    
  })
  
  subsetData <- reactive({
    # if (input$filter == "Todas as espécies") vetores
    if (length(input$species_filter) != 0) {
      vetores %>% filter(Species %in% input$species_filter)
    } else {
     vetores %>% filter(Species == "") 
    } 
  }) #close subsetData
  
  
  ### Mapa
  observeEvent(input$filter, {
    if (input$filter == "Selecionar espécie") {
      leafletProxy("map") %>%
        clearMarkers() %>%
        clearShapes() %>% 
        clearControls()
    } else {
      leafletProxy("map") %>%
        clearMarkers() %>%
        clearShapes() %>%
        addCircleMarkers(data = vetores, lng = ~Longitude, lat = ~Latitude, layerId=~codigo,
                         color = ~factPal(Infection), radius = 2, fillOpacity = 1,
                         popup = paste("ID", vetores$ID, "<br>",
                                       "Espécie:",  vetores$Species, "<br>",
                                       "Referência:", vetores$Reference, "<br>",
                                       "Ano de publicação:", vetores$Publication.Year, "<br>",
                                       "Data de inicio da coleta:", vetores$Collection_data_start, "<br>",
                                       "Data final da coleta:", vetores$Collection_data_end,"<br>",
                                       "Estado:", vetores$State, "<br>",
                                       "Município:", vetores$Municipality,"<br>",
                                       "Localização:", vetores$Location, "<br>"))
    }
  })
  
  observeEvent(input$species_filter,{
    leafletProxy("map") %>%
      clearMarkers() %>%
      clearShapes() %>%
      addCircleMarkers(data = subsetData(), lng = ~Longitude, lat = ~Latitude, layerId=~codigo,
                       color = ~factPal(subsetData()$Infection), radius = 2, fillOpacity = 1,
                       popup = paste("ID", subsetData()$ID, "<br>",
                                     "Espécie:",  subsetData()$Species, "<br>",
                                     "Referência:", subsetData()$Reference, "<br>",
                                     "Ano de publicação:", subsetData()$Publication.Year, "<br>",
                                     "Data de inicio da coleta:", subsetData()$Collection_data_start, "<br>",
                                     "Data final da coleta:", subsetData()$Collection_data_end,"<br>",
                                     "Estado:", subsetData()$State, "<br>",
                                     "Município:", subsetData()$Municipality,"<br>",
                                     "Localização:", subsetData()$Location, "<br>"))  
  }) # close observeEvent
  
  observeEvent(input$species_filter, {
    factPal <- colorFactor(palette = "inferno", levels = infection_select, ordered = FALSE)
    proxy <- leafletProxy("map", data = subsetData())
    
    proxy %>% 
      clearControls() %>% 
      addLegend(position = "bottomright", title = "Detecção de <i>Plasmodium sp</i>",
                pal = factPal, values = ~Infection)
    
  })
  
  
  
}) ### close Server function



#################################### ----------------------- UI -------------------------- ###########################################################33

ui <- bootstrapPage(
  navbarPage(theme = shinytheme("flatly"), collapsible = TRUE,
             HTML('<a style="text-decoration:none;cursor:default;color:white;" "background-color:white;" class="active" href="#">Plataforma de Vetores da Malária</a>'),
             tags$head(tags$style(HTML('.navbar-static-top {background-color: #BE1724;}',
                                       '.navbar-default .navbar-nav>.active>a {background-color: #BE1724;}'))),
             windowTitle = "Malaria Vector platform"),
  #-------------------------------- ui - aba Mapa de Espécies -----------------------------------------------
  tabPanel("Mapa de Vetores",
           div(class="outer",
               tags$head(includeCSS("styles.css")),
               leafletOutput('map',width="100%", height="100%"),
               
               absolutePanel(id = "controls", class = "panel panel-default",
                             top = 180, left = 55, width = 400, fixed=TRUE,
                             draggable = TRUE, height = "auto",
                             
                             span(tags$i(h6("Vetores por Espécie")),
                                  style="color:#045a8d"),
                             span(tags$i(h6("Digite a espécie para ver em qual localização e ano foi coletado. Para ver mais informações clique em cima do ponto no mapa")),
                                  style="color:#045a8d"),
                             awesomeRadio("filter", label=NULL, choices = c("Todas as espécies", "Selecionar espécie"), 
                                          inline = FALSE, status = "primary", checkbox = TRUE),
                             conditionalPanel(condition="input.filter=='Selecionar espécie'",
                                              selectizeInput("species_filter",
                                                             label = 'Espécies: ',
                                                             selected = "Todas",
                                                             multiple = TRUE,
                                                             choices = species_select,
                                                             options = list(
                                                               placeholder = 'Digite para procurar a espécie',
                                                               onInitialize = I('function() { this.setValue(""); }')
                                                             )
                                                             
                                              )),
                             # conditionalPanel(condition="input.filter=='Infecção'",
                             #                  selectizeInput("infection_filter",
                             #                                 choices = infection_select,
                             #                                 label = "Existência de infecção natural:"))
                             
                             
               )
           )
           
  ))




shinyApp(ui, server)
