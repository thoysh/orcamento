## UI Module ##
receiptUI <- function(id) {
  ns <- NS(id)

  tagList(
    tabPanel("Recibo",
             selectInput(ns("inSel_person"), "Quem pagou?", choices = c("Jorge", "Márcia")),
             numericInput(ns("inNum_value"), "Qual valor", value = 0.99, min = 0, max = 10000),
             selectInput(ns("inSel_tag"), "Categoria", choices = c("Selecione")),
             selectInput(ns("inSel_subtag"), "Subcategoria", choices = c("Selecione")),
             textAreaInput(ns("inTxt_comments"), "Comentários", width = '100%'),
             br(),
             textOutput(ns("outTxt_validate")),
             actionButton(ns("btn_insertReceipt"), "Inserir registro")
    )
  )
}


## SERVER Module ##
receiptServer <- function(input, output, session, RV, rac_receiptDB) {

  observe({
    updateSelectInput(session = session, "inSel_tag", choices = vetTag)
  })

  observeEvent(input$inSel_tag, {
    if (input$inSel_tag != "Selecione")
      updateSelectInput(session = session, "inSel_subtag", choices = lstSubtag[[input$inSel_tag]])
  })

  ## REACTIVE Valida Formulário de Recibo
  rac_validateReceipt <- reactive({
    shiny::validate(need(input$inSel_person %in% c("Jorge", "Márcia"),
                         "Escolha uma pessoa!"))
    shiny::validate(need(!is.na(as.numeric(input$inNum_value)),
                         "Digite um valor."))
    shiny::validate(need(input$inSel_tag %in% vetTag,
                         "Escolha uma categoria!"))
    if (input$inSel_tag != "Selecione")
      shiny::validate(need(input$inSel_subtag %in% lstSubtag[[input$inSel_tag]],
                           "Escolha uma subcategoria!"))
  })
  output$outTxt_validate <- renderText({ rac_validateReceipt() })

  ## BOTAO Salva recibo no BD
  observeEvent(input$btn_insertReceipt, {
    isolate({
      rac_validateReceipt()
      if (input$btn_insertReceipt != 0) {
        tryCatch({
          df <- data.frame(Pessoa            = input$inSel_person %>% as.character(),
                           Valor             = input$inNum_value %>% as.numeric(),
                           Categoria         = input$inSel_tag %>% as.character(),
                           Subcategoria      = input$inSel_subtag %>% as.character(),
                           Observacao        = input$inTxt_comments) %>%
            mutate(across(where(is.factor), as.character)) %>%
            mutate(across(where(is.character), str_squish))

          set_receipt(df, RV$user)
          shinyalertTy("Sucesso na inserção", type = "success")

          RV$upd_receipt <- RV$upd_receipt + 1

        }, error = function(e) {
          flog.error("btn_insertReceipt (E) | %s", e$message)
          shinyalertTy("Erro na inserção", type = "error")
        })
      }
    })
  })


  return(RV)
}
