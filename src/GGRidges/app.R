library(shiny)
library(devtools)
library(rCharts)
library(shinydashboard)
library(tidyverse)
library(htmlwidgets)
library(plotly)
library(ggplot2)
library(ggridges)

viz2 <- readxl::read_excel('txpositivo.xlsx') %>% 
  janitor::clean_names()

summary(viz2)
names(viz2)

library(hash)
ufsExtenso <- hash()
ufsExtenso[['AC']] <- 'Acre'
ufsExtenso[['AL']] <- 'Alagoas'
ufsExtenso[['AP']] <- 'Amapá'
ufsExtenso[['AM']] <- 'Amazonas'
ufsExtenso[['BA']] <- 'Bahia'
ufsExtenso[['CE']] <- 'Ceará'
ufsExtenso[['DF']] <- 'Distrito Federal'
ufsExtenso[['ES']] <- 'Espírito Santo'
ufsExtenso[['GO']] <- 'Goiás'
ufsExtenso[['MA']] <- 'Maranhão'
ufsExtenso[['MT']] <- 'Mato Grosso'
ufsExtenso[['MS']] <- 'Mato Grosso do Sul'
ufsExtenso[['MG']] <- 'Minas Gerais'
ufsExtenso[['PA']] <- 'Pará'
ufsExtenso[['PB']] <- 'Paraíba'
ufsExtenso[['PR']] <- 'Paraná'
ufsExtenso[['PE']] <- 'Pernambuco'
ufsExtenso[['PI']] <- 'Piauí'
ufsExtenso[['RJ']] <- 'Rio de Janeiro'
ufsExtenso[['RN']] <- 'Rio Grande do Norte'
ufsExtenso[['RS']] <- 'Rio Grande do Sul'
ufsExtenso[['RO']] <- 'Rondônia'
ufsExtenso[['RR']] <- 'Roraima'
ufsExtenso[['SC']] <- 'Santa Catarina'
ufsExtenso[['SP']] <- 'São Paulo'
ufsExtenso[['SE']] <- 'Sergipe'
ufsExtenso[['TO']] <- 'Tocantins'

viz2$uf <- sapply(viz2$uf, function(x) ufsExtenso[[x]])

header <- dashboardHeader(title = "Proporção de Casos Positivos (2007 - 2019)")

#Sidebar content of the dashboard
sidebar <- dashboardSidebar()


frow1 <- fluidRow(
  box(
    title = "Chart",
    status = "warning",
    plotOutput("PlotRidges"),
    solidHeader = TRUE,
    collapsible = TRUE,
    footer = HTML('Fonte: Sistema de Informações de Vigilância Epidemiológica (SIVEP) - Malária <br/> População residente segundo IBGE')
  )
)

body <- dashboardBody(frow1)

ui <- dashboardPage(title = 'GGRidges', header, sidebar, body, skin='black')

server <- shinyServer(function(input, output) { 
  data_input <- reactive({
    subset(viz2, uf == input$uf)
  })

 output$PlotRidges <- renderPlot({
    ggplot(viz2, aes(x = propositivo, y = uf, fill = stat(x))) +
    geom_density_ridges_gradient(scale = 3, rel_min_height = 0.01) +
    scale_fill_viridis_c(name = "%", option = "C") + xlim(0,36)+
    theme(legend.position = 'none')+
    labs(title = 'Proporção de casos positivos entre os casos investigados segundo Unidade da Federação, 2007-2019') +
    labs(x = "Proporção (%)",
          y = "Unidade da Federação-UF") +
    labs(caption = "Fonte: SIVEP Malaria, 2007-2019") })
})

shinyApp(ui, server)
