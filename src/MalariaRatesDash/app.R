#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(devtools)
library(rCharts)
library(shinydashboard)


ObitosIdade <- read.table ("TBMPad_TxInc.csv", fileEncoding="utf8", header = T ,sep=',', dec='.')

ObitosIdade$Ano <- as.numeric(ObitosIdade$Ano)

header <- dashboardHeader(title = "Malaria - Brasil")  

#Sidebar content of the dashboard
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Dashboard", tabName = "Choose State", icon = icon("dashboard")),
  
    selectInput(inputId = "uf",
                label = "Escolha um Estado:",
                choices = unique(ObitosIdade$UF),
                selected = "RO")
  )
  
)


frow1 <- fluidRow(
  
  box(
    title = "Taxas de Incidência do estado selecionado:"
    ,status = "warning"
    ,solidHeader = TRUE 
    ,collapsible = TRUE 
    ,showOutput("plotIncidence", "nvd3")
    ,footer = HTML('Fonte: Sistema de Informações de Vigilância Epidemiológica (SIVEP) - Malária <br/> População Residêncial por IBGE'
  ))
  
  ,box(
    title = "Taxas de mortalidade padronizadas por idade* de malária do estado selecionado"
    ,status = "danger"
    ,solidHeader = TRUE 
    ,collapsible = TRUE 
    ,showOutput("PlotDeath","nvd3")
    ,footer = HTML('Fonte: Datasus - Malaria <br/> População Residêncial por IBGE </br> 
    *Padrão por idade define uma idade constante da população & estrutura (População do Brasil, 2010) para permitir a comparação entre estados e
    com tempo'
  )) 
  
)

# combine the two fluid rows to make the body
body <- dashboardBody(frow1)

ui <- dashboardPage(title = 'Taxas de Malária - Brasil', header, sidebar, body, skin='black')

# create the server functions for the dashboard  
server <- shinyServer(function(input, output) { 
  
  #creating the plotOutput content
  data_input <- reactive({
  subset(ObitosIdade, UF == input$uf)
})
  
output$PlotDeath <- renderChart({
  
  pt1 <- nPlot(y = 'TEMPad', x = 'Ano', group = 'Idade', data =  data_input() , 
               type = 'stackedAreaChart')
  pt1$chart(useInteractiveGuideline=TRUE, showControls = F, margin = list(left = 100, right = 100))
  pt1$addParams(dom = 'PlotDeath')
  pt1$xAxis(tickValues = ObitosIdade$Ano)
  pt1$yAxis(axisLabel = "Taxas de mortalidade padronizadas por idade por 100.000 habitantes")
  return(pt1)
})

output$plotIncidence <- renderChart({
  
  pt2<-nPlot(TxInc~Ano, group = 'Idade', data =  data_input(), 
             type = 'stackedAreaChart')
  pt2$chart(useInteractiveGuideline=TRUE, showControls = F, margin = list(left = 100, right = 100))
  pt2$addParams(dom = 'plotIncidence')
  pt2$xAxis(tickValues = ObitosIdade$Ano)
  pt2$yAxis(axisLabel = "Taxas de incidência por 1.000 habitantes")
  return(pt2)
  
})

})


shinyApp(ui, server)
