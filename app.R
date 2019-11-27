library(shiny)
library(shinydashboard)
library(shinyalert)
library(mongolite)
library(ndjson)
library(rapportools)
library(anytime)
library(lubridate)
library(quanteda)
library(spacyr)
library(plotly)
library(openxlsx)
library(DT)
library(topicmodels)

docker = T

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
source("modules/display table.R")
source("modules/preprocessing.R")
source("modules/upload dic.R")
source("modules/select dic.R")
source("modules/modify dic.R")
source("modules/compare dics.R")
source("modules/info.R")
source("modules/timeseries.R")
source("modules/collocations.R")
source("modules/target collocations.R")
source("modules/sentiment.R")
source("modules/topic modelling.R")

#Erzeugung der gemeinsamen Datenbasis
assign(
  "global",
  reactiveValues(
    m = mongoDB(db = "data"),
    data = NULL,
    coll = NULL,
    corpus = NULL,
    tokens = NULL,
    dfm = NULL,
    nlp = NULL,
    mdic = mongoDB(db = "dics"),
    dic = NULL,
    dicoll = NULL
  ),
  envir = .GlobalEnv
)


#UI sowohl fürs Dashboard als auch die Elemente auf den einzelnen Tabs
ui <- dashboardPage(
  dashboardHeader(title = "DexDminer"),
  dashboardSidebar(sidebarMenu(
    menuItem("Data Selection",
             tabName = "data_selection",
             icon = icon("database")),
    menuItem("Preprocessing",
             tabName = "preprocessing",
             icon = icon("edit")),
    menuItem("Dictionary Selection",
             tabName = "dictionary",
             icon = icon("book")),
    menuItem("Compare Dictionares",
             tabName = "compare_dics",
             icon = icon("book")),
    menuItem("Timeseries",
             tabName = "timeseries",
             icon = icon("history")),
    menuItem("Collocations",
             tabName = "collocations",
             icon = icon("text-size", lib = "glyphicon")),
    menuItem("Target Collocations",
             tabName = "target_collo",
             icon = icon("bullseye")),
    menuItem("Sentiment Analysis",
             tabName = "sentiment",
             icon = icon("smile")),
    menuItem("Topic Modelling",
             tabName = "topic",
             icon = icon("project-diagram"))
    )
  ),
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
    tabItem(
      tabName = "dictionary",
      column(
        4,
        box(
          title = "Upload a dictionary...",
          uploadDicUI("upDic"),
          collapsible = TRUE,
          collapsed = TRUE,
          width = 12
        ),
        box(title = "...or select an existing one.",
            selectDicUI("selDic"),
            width = 12
        )
      ),
      column(
        6,
        box(
          title = "Modify the dictionary",
          modifyDicUI("modDic"),
          width = 12
        )
      )
    ),
    tabItem(tabName = "compare_dics",
            box(title = "Compare two dictionaries",
                compareDicsUI("compare"))),
    tabItem(tabName = "timeseries",
            box(title = "Single Word Timeseries",
                timeseriesUI("timeseries"))),
    tabItem(tabName = "collocations",
            box(title = "Collocations",
                collocationUI("collocations"))),
    tabItem(tabName = "target_collo",
            box(title = "Target Collocations",
                targetColloUI("target"))),
    tabItem(tabName = "sentiment",
            box(title = "Sentiment Analysis",
                sentimentUI("sentiment"))),
    tabItem(tabName = "topic",
            box(title = "Topic Modelling",
                tmUI("tm")))
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
  callModule(uploadDic, "upDic")
  callModule(selectDic, "selDic")
  callModule(modifyDic, "modDic")
  callModule(compareDics, "compare")
  callModule(timeseries, "timeseries")
  callModule(collocation, "collocations")
  callModule(targetCollo, "target")
  callModule(sentiment, "sentiment")
  callModule(tm, "tm")
  callModule(info, "data_info")
  callModule(info, "prep_info")
  session$onSessionEnded(stopApp)
}

shinyApp(ui = ui, server = server)
