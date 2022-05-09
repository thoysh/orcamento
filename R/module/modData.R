## UI Module ##
dataUI <- function(id) {
  ns <- NS(id)

  tagList(
    tabPanel("Histórico",
             withSpinnerTy(DT::DTOutput(ns("tbl_receiptHistoric")))
    )
  )
}


## SERVER Module ##
dataServer <- function(input, output, session, RV, rac_receiptDB) {

  ## OUTPUT Histórico de recibos
  output$tbl_receiptHistoric <- DT::renderDT({
    RV$upd_receipt
    req(rac_receiptDB())
    df <- rac_receiptDB()
    df <- df %>%
      select(-CriadoPor) %>%
      mutate(Excluir = fshinySetInput(actionButton, df$`_id`, "btn_delReceipt",
                                      label = icon("times"),
                                      onclick = paste0('Shiny.setInputValue("', session$ns(""),
                                                       'selBtn_delReceipt", this.id, {priority: "event"})')))

    datatableTy(df, nome = "Recibos",
                class = "nowrap",
                # extensions = "FixedColumns",
                escape = ncol(df) - 1,
                options = list(scrollX = T,
                               columnDefs = list(list(visible = F, targets = c(0)))),
                callback = JS("table.order([5, 'asc']).draw();")) %>%
      formatCurrency(names(df) == "Valor", currency = "", mark = ".", dec.mark = ",", digits = 2) %>%
      # formatDate(names(Filter(is.Date, df)), method = "toLocaleDateString", params = "pt-BR") %>%
      formatDate(names(Filter(is.POSIXct, df)), method = "toLocaleString", params = "pt-BR")
  })


  ## BOTAO Exclui recibos
  observeEvent(input$selBtn_delReceipt, {
    selId <- strsplit(input$selBtn_delReceipt, "-")[[1]][-1]

    del_receipt(id = selId, user = RV$user)
    shinyalertTy("Sucesso na exclusão", paste0("Recibo id ", selId), type = "success")
    RV$upd_receipt <- RV$upd_receipt + 1
  })


  return(RV)
}
