
# mainPanel(
#   tags$h4("Feel free to explore the data a bit before saving to MongoDB"),
#   tags$em("It may take a moment for the file to be processed...", id = "temp"),
#   dataTableOutput("inputView")
# )


# output$inputView <- renderDataTable({
#   if (is.data.frame(df()))
#     removeUI(selector = "#temp")
#   df()
# })
