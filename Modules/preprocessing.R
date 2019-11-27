library(shiny)
library(spacyr)
library(quanteda)

preprocessUI <- function(id) {
  ns <- NS(id)
  tagList(
    # Token Object Optionen und Button
    column(4,
           checkboxGroupInput(ns("tokOpt"), "Token Options",
                              choiceNames = c("Remove Numbers",
                                              "Remove Punctuation",
                                              "Remove Symbols",
                                              "Remove Separators",
                                              "Remove URLs",
                                              "Remove Stopwords"),
                              choiceValues = c("nums",
                                               "punct",
                                               "symbols",
                                               "separators",
                                               "urls",
                                               "stopwords"),
                              selected = c("nums",
                                           "punct",
                                           "symbols",
                                           "separators",
                                           "stopwords")),
           selectInput(ns("language"),
                       "Please select the language",
                       choices = c(English = "en", German = "de")),
           actionButton(ns("createTokens"), "Create Tokens")
           ),
    # DFM Optionen und Button
    column(4,
           checkboxGroupInput(ns("dfmOpt"), "DFM Options",
                              choiceNames = c("All Lowercase",
                                              "Stemming"),
                              choiceValues = c("tolower",
                                               "stem"),
                              selected = c("tolower")),
           actionButton(ns("createDFM"), "Create DFM")
           ),
    # NLP Optionen und Button
    column(4,
           checkboxGroupInput(ns("nlpOpt"), "NLP Options",
                              choiceNames = c("Universal POS tags",
                                              "Detailed POS tags",
                                              "Lemmatized Tokens",
                                              "Named Entities",
                                              "Tag Dependencies",
                                              "Nounphrases"),
                              choiceValues = c("pos",
                                               "tag",
                                               "lemma",
                                               "entity",
                                               "dependency",
                                               "nounphrase"),
                              selected = c("pos",
                                           "lemma",
                                           "entity")),
           actionButton(ns("createNLP"), "Create NLP Set")
           )
  )
}


preprocess <- function(input, output, session) {

  # setzt die Buttons beim Auswählen einer anderen Collection zurück
  observeEvent(global$coll, {
    updateActionButton(session, "createTokens", label = "Create Tokens")
    updateActionButton(session, "createDFM", label = "Create DFM")
    updateActionButton(session, "createNLP", label = "Create NLP Set")
  })

  # Beim Klick auf den Create Button wird ein Token Object entsprechend der ausgewählten Optionen erzeugt
  observeEvent(input$createTokens, {
    global$tokens <- tokens(req(global$corpus),
                            what = "word",
                            remove_numbers = ("nums" %in% input$tokOpt),
                            remove_punct = ("punct" %in% input$tokOpt),
                            remove_symbols = ("symbols" %in% input$tokOpt),
                            remove_urls = ("urls" %in% input$tokOpt),
                            include_docvars = TRUE)

    if ("stopwords" %in% input$tokOpt)
      global$tokens <- tokens_remove(global$tokens,
                                     pattern = stopwords(input$language))

    updateActionButton(session, "createTokens", label = "Tokens created")
  })

  # Beim Klick auf den Create Button wird eine DFM aus dem Token Object erzeugt entspr. der Optionen
  observeEvent(input$createDFM, {
    global$dfm <- dfm(req(global$tokens),
                      tolower = ("tolower" %in% input$dfmOpt),
                      stem = ("stem" %in% input$dfmOpt))

    updateActionButton(session, "createDFM", label = "DFM created")
  })

  observeEvent(input$createNLP, {
    spacy_initialize(
      python_executable = py_ex,
      entity = ("entity" %in% input$nlpOpt))
    global$nlp <- spacy_parse(req(global$corpus),
                              pos = ("pos" %in% input$nlpOpt),
                              tag = ("tag" %in% input$nlpOpt),
                              lemma = ("lemma" %in% input$nlpOpt),
                              entity = ("entity" %in% input$nlpOpt),
                              dependency = ("dependency" %in% input$nlpOpt),
                              nounphrase = ("nounphrase" %in% input$nlpOpt))
    spacy_finalize()
    updateActionButton(session, "createNLP", label = "NLP Set created")
  })
}