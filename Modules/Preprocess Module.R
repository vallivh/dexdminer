source(paste0(getwd(), "/Modules/MongoDB parser.R"), local = TRUE)


preprocessUI <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("textFields")),
    actionButton(ns("createIndex"), "Create Text Index")
  )
}


preprocess <- function(input, output, session, df_runtime, coll_runtime) {
  
  output$textFields <- renderUI({
    selectInput("fieldInput", 
                "Which fields contain textual data?", 
                choices = colnames(df_runtime()), 
                multiple = TRUE)
  })
  
  observeEvent(input$createIndex, {
    m <- mongoDB(collection = coll_runtime())
    print(input$fieldInput)
    print(parseIndex(input$fieldInput, name = "textIndex"))
    #m$index(add = parseIndex("textFields", name = "textIndex"))
    updateActionButton(session, "createIndex", label = "Index created")
  })
}


# #return some data for visual overview and to fetch variable names to select
# ds <- reactive({
#   db()$find(query = '{}', limit = 50)
# })  
# 
# output$selectVar <- renderUI({
#   
#   checkboxGroupInput("varSelected", 
#                      "Please select variables", 
#                      choices = colnames(ds()), 
#                      selected = colnames(ds()), 
#                      inline = FALSE)
# })