library(mongolite)
library(jsonlite)
library(ndjson)
library(readtext)
library(shiny)
library(shinydashboard)
library(shinyalert)
library(nycflights13)

source(paste0(getwd(),"/Modules/Upload Module.R"), local = TRUE)
source(paste0(getwd(),"/Modules/Select Module.R"), local = TRUE)
source(paste0(getwd(),"/Modules/Preprocess Module.R"), local = TRUE)
source(paste0(getwd(),"/Modules/Display Table Module.R"), local = TRUE)

#Erzeugung der gemeinsamen Datenbasis
assign("df_runtime", reactiveVal(), envir = .GlobalEnv)
assign("coll_runtime", reactiveVal(), envir = .GlobalEnv)
assign("corp_runtime", reactiveVal(), envir = .GlobalEnv)


#UI sowohl fürs Dashboard als auch die Elemente auf den einzelnen Tabs
ui <- dashboardPage(
  dashboardHeader(title = "Testing Tool"),
  dashboardSidebar(
    sidebarMenu(
      menuItem(
        "Data Selection",
        tabName = "data_selection",
        icon = icon("database")
      ),
      menuItem(
        "Sentiment Analysis",
        tabName = "sentiment",
        icon = icon("smile")
      )
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "data_selection",
        fluidRow(
          column(6,
                 box(title = "Upload a dataset...",
                     uploadUI("upload"),
                     collapsible = TRUE,
                     collapsed = TRUE,
                     width = 12),
                 box(title = "...or select an existing one.",
                     selectUI("select"),
                     width = 12)
          ),
          column(6,
                 box(title = "Preprocessing",
                     preprocessUI("prep"),
                     width = 12))
        ),
        fluidRow(
          tags$h2("Explore the data", style = "text-align:center"),
          displayTableUI("table")
        )
      )
    )
  )
)

server <- function(input, output, session){
  callModule(upload, "upload", coll_runtime())
  callModule(select, "select", coll_runtime())
  callModule(preprocess, "prep", coll_runtime())
  observeEvent(df_runtime(), {callModule(displayTable, "table", df_runtime())})
  session$onSessionEnded(stopApp)
}

shinyApp(ui = ui, server = server)
