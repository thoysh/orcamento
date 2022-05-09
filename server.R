## server.R ##
# Define a lógica do servidor do Shiny web app

# Define a lógica da sessão ----

# Define a lógica do servidor ----
server <- function(input, output, session) {
  setupFutilelogger(TRACE) # Setup futilelogger

  RV <- reactiveValues()
  RV$user <- "J&M"
  RV$upd_receipt <- 0

  rac_receiptDB <- reactive({
    RV$upd_receipt
    get_receipt()
  })

  callModule(module = receiptServer, "receipt",  RV, rac_receiptDB)
  callModule(module = dataServer,    "data",     RV, rac_receiptDB)

}
