library(mongolite)
library(ndjson)
library(rapportools)
library(shiny)
library(shinydashboard)
library(shinyalert)
library(anytime)
library(quanteda)
library(spacyr)
library(plotly)

assign("global_db", "mongotest", envir = .GlobalEnv)

source("Modules/MongoDB parser.R")
source("Modules/Upload Module.R")
source("Modules/Select Module.R")
source("Modules/Dataprep Module.R")
source("Modules/Preprocessing Module.R")
source("Modules/Display Table Module.R")
source("Modules/Sentiment Module.R")
source("Modules/Info Module.R")

#Erzeugung der gemeinsamen Datenbasis
assign(
  "global",
  reactiveValues(
    m = mongoDB(),
    data = NULL,
    coll = NULL,
    corpus = NULL,
    tokens = NULL,
    dfm = NULL,
    nlp = NULL
  ),
  envir = .GlobalEnv
)


#UI sowohl fürs Dashboard als auch die Elemente auf den einzelnen Tabs
ui <- dashboardPage(
  dashboardHeader(title = "Testing Tool"),
  dashboardSidebar(sidebarMenu(
    menuItem(
      "Data Selection",
      tabName = "data_selection",
      icon = icon("database")
    ),
    menuItem("Preprocessing",
             tabName = "preprocessing",
             icon = icon("edit")),
    menuItem(
      "Sentiment Analysis",
      tabName = "sentiment",
      icon = icon("smile")
    )
  )),
  dashboardBody(tabItems(
    tabItem(
      tabName = "data_selection",
      fluidRow(column(
        4,
        box(
          title = "Upload a dataset...",
          uploadUI("upload"),
          collapsible = TRUE,
          collapsed = TRUE,
          width = 12
        ),
        box(title = "...or select an existing one.",
            selectUI("select"),
            width = 12)
      ),
      column(
        4,
        box(
          title = "Data Preparation",
          dataprepUI("data"),
          collapsible = TRUE,
          width = 12
        )
      ),
      column(4,
             infoUI("data_info"))),
      fluidRow(
        tags$h2("Explore the data", style = "text-align:center"),
        displayTableUI("table")
      )
    ),
    tabItem(tabName = "preprocessing",
            column(
              8,
              box(title = "Preprocessing",
                  preprocessUI("prep"),
                  width = 12)
            ),
            column(4,
                   infoUI("prep_info"))),
    tabItem(tabName = "sentiment",
            box(title = "Sentiment Analysis",
                sentimentUI("sentiment")))
  ))
)

server <- function(input, output, session) {
  callModule(upload, "upload")
  callModule(select, "select")
  callModule(dataprep, "data")
  observeEvent(global$data, {
    callModule(displayTable, "table", global$data)
    })
  callModule(preprocess, "prep")
  callModule(sentiment, "sentiment")
  callModule(info, "data_info")
  callModule(info, "prep_info")
  session$onSessionEnded(stopApp)
}

shinyApp(ui = ui, server = server)
