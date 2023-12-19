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

suppressMessages({
  municipios <- st_read('municipios_limite.gpkg', as_tibble = T, quiet = T)
  vetores <- read.csv("Dados Vetores.csv", dec = ',', sep = ";", encoding = "ISO-8859-1")
  
  vetores <- vetores %>% 
    mutate(
      Species = gsub("\u00a0", " ", Species), # Non breaking space
      Species = gsub("\\s{2,5}", " ", Species), # Multiple whitespaces
      Species = trimws(Species),
      Infection = factor(Infection, c("Sim", "Não", ""), c("Yes", "No", "NA"))) %>%
        select(
          ID, codigo, Species, Municipality, State, Collection_data_start,
          Collection_data_end, Location, Latitude, Longitude, Reference,
          Publication.Year, Infection
        ) %>% 
          distinct()
  vetores %>% pull(Species) %>% unique() %>% sort()
  desmatamento <- read.csv("df_floresta.csv", dec = ",", sep = ";", na.strings = "no record")
  desmatamento <- unique(desmatamento)
})

species_select <- vetores %>% pull(Species) %>% unique() %>% sort()
infection_select <- vetores %>% pull(Infection) %>% unique() %>% sort()

munic_names <- municipios %>%
  st_drop_geometry() %>%
    select(code_muni, name_muni)

municipios2 <- municipios %>%
  st_make_valid() %>%
    filter(code_state %in% c(11:17, 21, 51)) %>%
      select(code = code_muni, name = name_muni) %>%
        mutate(cod6 = as.integer(substr(code, 1, 6))) %>%
          select(-code) %>%
            st_transform(crs = 4326)

base_bb <- st_sf(
  a = 1:2,
  geom = st_sfc(
    st_point(c(-1212183.85, 7945639.07)),
    st_point(c(1850099.70, 10557683.96))
  ),
  crs = 4326
)

tmpPal <- c("#000000", "#BB3655", "#FFEB3B")

server <- shinyServer(function(input, output, session) {
  #factPal <- colorFactor(palette = "inferno", levels = infection_select, ordered = FALSE)
  factPal <- colorFactor(palette = tmpPal, levels = infection_select, ordered = FALSE)

  output$map <- renderLeaflet({
    basemap <- municipios2 %>%
      st_make_valid()
    
    leaflet(basemap, options = leafletOptions(minZoom = 5, maxZoom = 18)) %>%
      addProviderTiles(provider = "OpenStreetMap.Mapnik") %>%
        fitBounds(-75, -18, -46, 5) %>%
          addCircleMarkers(
            data = vetores,
            lng = ~Longitude,
            lat = ~Latitude,
            layerId = ~codigo,
            color = factPal(~Infection),
            radius = 5,
            fillOpacity = 1,
            stroke = FALSE,
            popup = paste(
              "ID", ~ID, "<br>",
              "Species:",  ~Species, "<br>",
              "Reference:", ~Reference, "<br>",
              "Publication year:", ~Publication.Year, "<br>",
              "Collection start date:", ~Collection_data_start, "<br>",
              "Collection end date:", ~Collection_data_end,"<br>",
              "State:", ~State, "<br>",
              "Municipality:", ~Municipality,"<br>",
              "Location:", ~Location, "<br>"
            )
          ) %>%  
            addLegend(
              position = "bottomright",
              title = "<span style=\"font-style:italic\">Plasmodium sp.</span> detection",
              data = vetores,
              pal = factPal,
              values = ~Infection,
              opacity = 1
            )
  })

  observeEvent(input$filter, {
    updateSelectizeInput(
      session,
      "species_filter", 
      label = NULL,
      choices = species_select, 
      selected = character(0), 
      options = list(
        maxOptions = 1000,
        placeholder = "Search for species",
        render = I('{
          option: function(item, escape) {
            const label = escape(item.label);
            return \'<div style="padding-left:1rem;padding-top:0.25rem;padding-bottom:0.25rem;font-style:italic;">\' + label + \'</div>\';
          },
          item: function(item, escape) {
            const label = escape(item.label);
            return \'<div style="font-style:italic;">\' + label + \'</div>\';
          },
        }')
      )
    )
  })

  subsetData <- reactive({
    if (length(input$species_filter) != 0) {
      vetores %>%
        filter(Species %in% input$species_filter)
    } else {
      vetores %>%
        filter(Species == "") 
    } 
  })

  observeEvent(input$filter, {
    if (input$filter == "Select species") {
      leafletProxy("map") %>%
        clearMarkers() %>%
          clearShapes() %>% 
            clearControls() %>%
              addLegend(
                position = "bottomright",
                title = "<span style=\"font-style:italic\">Plasmodium sp.</span> detection",
                data = vetores,
                pal = factPal,
                values = ~Infection,
                opacity = 1
              )
    } else {
      leafletProxy("map") %>%
        clearMarkers() %>%
          clearShapes() %>%
            clearControls() %>%
              addCircleMarkers(
                data = vetores,
                lng = ~Longitude,
                lat = ~Latitude,
                layerId=~codigo,
                color = ~factPal(Infection),
                radius = 5,
                fillOpacity = 1,
                stroke = FALSE,
                popup = paste(
                  "ID", vetores$ID, "<br>",
                  "Species:",  vetores$Species, "<br>",
                  "Reference:", vetores$Reference, "<br>",
                  "Publication year:", vetores$Publication.Year, "<br>",
                  "Collection start date:", vetores$Collection_data_start, "<br>",
                  "Collection end date:", vetores$Collection_data_end,"<br>",
                  "State:", vetores$State, "<br>",
                  "Municipality:", vetores$Municipality,"<br>",
                  "Location:", vetores$Location, "<br>"
                )
              ) %>%
                addLegend(
                  position = "bottomright",
                  title = "<span style=\"font-style:italic\">Plasmodium sp.</span> detection",
                  data = vetores,
                  pal = factPal,
                  values = ~Infection,
                  opacity = 1
                )
    }
  })

  observeEvent(input$species_filter, {
    leafletProxy("map") %>%
      clearMarkers() %>%
        clearShapes() %>%
          clearControls() %>%
            addCircleMarkers(
              data = subsetData(),
              lng = ~Longitude,
              lat = ~Latitude,
              layerId=~codigo,
              color = ~factPal(subsetData()$Infection),
              radius = 5,
              fillOpacity = 1,
              stroke = FALSE,
              popup = paste(
                "ID", subsetData()$ID, "<br>",
                "Species:",  subsetData()$Species, "<br>",
                "Reference:", subsetData()$Reference, "<br>",
                "Publication year:", subsetData()$Publication.Year, "<br>",
                "Collection start date:", subsetData()$Collection_data_start, "<br>",
                "Collection end date:", subsetData()$Collection_data_end,"<br>",
                "State:", subsetData()$State, "<br>",
                "Municipality:", subsetData()$Municipality,"<br>",
                "Location:", subsetData()$Location, "<br>"
              )
            ) %>%
              addLegend(
                position = "bottomright",
                title = "<span style=\"font-style:italic\">Plasmodium sp.</span> detection",
                data = vetores,
                pal = factPal,
                values = ~Infection,
                opacity = 1
              )
  })

  observeEvent(input$species_filter, {
    factPal <- colorFactor(palette = tmpPal, levels = infection_select, ordered = FALSE)
    proxy <- leafletProxy("map", data = subsetData())
    proxy %>% 
      clearControls() %>% 
        addLegend(
          position = "bottomright",
          title = "<span style=\"font-style:italic\">Plasmodium sp.</span> detection",
          data = vetores,
          pal = factPal,
          values = ~Infection,
          opacity = 1
        )
  })
})

ui <- bootstrapPage(
  navbarPage(
    theme = shinytheme("flatly"),
    collapsible = TRUE,
    HTML('<a style="text-decoration:none;cursor:default;color:white;" "background-color:white;" class="active" href="#">Malaria Vector platform</a>'),
    tags$head(
      tags$style(
        HTML('.navbar-static-top {background-color: #BE1724;}','.navbar-default .navbar-nav>.active>a {background-color: #BE1724;}')
      )
    ),
    windowTitle = "Malaria Vector platform"
  ),
  tabPanel(
    "Mapa de Vetores",
    div(
      class="outer",
      tags$head(includeCSS("styles.css")),
      leafletOutput('map', width="100%", height="100%"),
      absolutePanel(
        id = "controls",
        class = "panel panel-default",
        top = 180,
        left = 55,
        width = 400,
        fixed=TRUE,
        draggable = TRUE,
        height = "auto",
        span(
          tags$i(h6("Vectors by Species")),
          style="color:#045a8d"
        ),
        span(
          tags$i(h6("Type in a species to see where and when it was recorded. For more information, click the points on the map")),
          style="color:#045a8d"
        ),
        awesomeRadio(
          "filter",
          label=NULL,
          choices = c("All species", "Select species"),
          inline = FALSE,
          status = "primary",
          checkbox = TRUE
        ),
        conditionalPanel(
          condition="input.filter=='Select species'",
          selectizeInput(
            "species_filter",
            label = 'Species: ',
            selected = "All species",
            multiple = TRUE,
            choices = species_select,
            options = list(
              placeholder = 'Search for species',
              onInitialize = I('function() { this.setValue(""); }')
            )
          )
        ),
      )
    )       
  )
)

shinyApp(ui, server)
