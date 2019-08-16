library(shiny)
library(shinydashboard)
library(shinyalert)
library(mongolite)
library(jsonlite)

source(paste0(getwd(),"/Modules/Upload Module.R"), local = TRUE)

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
        tabName = "sentiment"
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
                     collapsed = FALSE),
                 box(title = "...or select an existing one."))
        )
      )
    )
  )
)

server <- function(input, output, session){
  callModule(upload, "upload")
}

shinyApp(ui = ui, server = server)
