#return some data for visual overview and to fetch variable names to select
ds <- reactive({
  db()$find(query = '{}', limit = 50)
})  

output$selectVar <- renderUI({
  
  checkboxGroupInput("varSelected", 
                     "Please select variables", 
                     choices = colnames(ds()), 
                     selected = colnames(ds()), 
                     inline = FALSE)
})