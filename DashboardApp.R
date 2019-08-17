library(shiny)
library(shinydashboard)
library(shinyalert)
library(mongolite)
library(jsonlite)
library(ndjson)
library(nycflights13)

source(paste0(getwd(),"/Modules/Upload Module.R"), local = TRUE)
source(paste0(getwd(),"/Modules/Select Module.R"), local = TRUE)
source(paste0(getwd(),"/Modules/Display Table Module.R"), local = TRUE)

#Erzeugung der gemeinsamen Datenbasis
assign("df_runtime", reactiveVal(), envir = .GlobalEnv)
assign("coll_runtime", reactiveVal(), envir = .GlobalEnv)

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
                     uploadUI("upload")),
                 box(title = "...or select an existing one.",
                     selectUI("select"))
          ),
          column(6,
                 box(title = "Preprocessing"))
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
  callModule(upload, "upload", df_runtime(), coll_runtime())
  callModule(select, "select", df_runtime(), coll_runtime())
  observeEvent(df_runtime(), {callModule(displayTable, "table", df_runtime())})
}

shinyApp(ui = ui, server = server)
