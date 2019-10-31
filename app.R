library(shiny)
library(shinydashboard)
library(shinyalert)
library(mongolite)
library(ndjson)
library(rapportools)
library(anytime)
library(quanteda)
library(spacyr)
library(plotly)

docker = F
assign("global_db", "data", envir = .GlobalEnv)

if (docker) {
  assign("mongo_ip", "mongodb", envir = .GlobalEnv)
  assign("py_ex", "/opt/conda/envs/spacy_condaenv/bin/python", envir = .GlobalEnv)
} else {
  assign("mongo_ip", "127.0.0.1", envir = .GlobalEnv)
  assign("py_ex", NULL, envir = .GlobalEnv)
}

source("functions/mongo parser.R")
source("modules/upload.R")
source("modules/select.R")
source("modules/dataprep.R")
source("modules/preprocessing.R")
source("modules/display table.R")
source("modules/timeseries.R")
source("modules/sentiment.R")
source("modules/info.R")

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
  dashboardHeader(title = "DexDminer"),
  dashboardSidebar(sidebarMenu(
    menuItem(
      "Data Selection",
      tabName = "data_selection",
      icon = icon("database")
    ),
    menuItem("Preprocessing",
             tabName = "preprocessing",
             icon = icon("edit")),
    menuItem("Timeseries",
             tabName = "timeseries",
             icon = icon("history")),
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
    tabItem(tabName = "timeseries",
            box(title = "Single Word Timeseries",
                timeseriesUI("timeseries"))),
    tabItem(tabName = "sentiment",
            box(title = "Sentiment Analysis",
                sentimentUI("sentiment")))
  ))
)

server <- function(input, output, session) {
  callModule(upload, "upload")
  callModule(select, "select")
  callModule(dataprep, "data")
  callModule(timeseries, "timeseries")
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
