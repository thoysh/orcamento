
vetTag <- c("Despesa Dia-a-Dia", "Despesa Fixa", "Despesa Incomum", "Renda")

lstSubtag <- list()
lstSubtag[["Selecione"]]         <- c("Selecione")
lstSubtag[["Renda"]]             <- c("Salário", "Bonus", "13o", "Outros")
lstSubtag[["Despesa Dia-a-Dia"]] <- c("Alimentação", "Saúde & Higiene", "Transporte & Gasolina", "Lazer")
lstSubtag[["Despesa Fixa"]]      <- c("Condomínio", "Luz", "Gás", "TV & Internet", "Celular", "Mercado & Feira", "Plano de saúde", "Plano dental")
lstSubtag[["Despesa Incomum"]]   <- c("Vestuário", "Presente", "Manutenção", "Outros")


#' Get recibos
#'
#' @return dataframe de recibos não-removidas
get_receipt <- function() {
  flog.info("Função | %s", as.character(sys.call()[1]))

  # Connect to the database
  db = mongo(collection = "receipt",
             db = Sys.getenv("MONGO_DB"), url = Sys.getenv("MONGO_URL"))
  # Read entries
  df <- db$find(query = '{ "RemovidoEm": null }',
                fields = '{}')
  if (ncol(df) == 0) return(NULL)
  if ("Data" %in% names(df))
    df$Data <- df$Data %>% as.Date()
  df
}


#' Get recibos por período
#'
#' @param dataDe date: data de início
#' @param dataAte date: data de fim
#'
#' @return dataframe de recibos não-removidas por período (considera criação)
get_receiptByDateCriadoEm <- function(dataDe, dataAte) {
  flog.info("Função | %s", as.character(sys.call()[1]))
  req(is.Date(c(dataDe, dataAte)))

  fmt <- '%Y-%m-%dT%H:%M:%S.000Z'

  # Connect to the database
  db = mongo(collection = "receipt",
             db = Sys.getenv("MONGO_DB"), url = Sys.getenv("MONGO_URL"))
  # # Read entries
  df <- db$find(query = paste0('{ "CriadoEm": { "$gte": { "$date": "', format(dataDe, fmt), '"},',
                               '                "$lte": { "$date": "', format(dataAte, fmt), '"}},',
                               '  "RemovidoEm": null }'))
  if (ncol(df) == 0) return(NULL)
  if ("Data" %in% names(df))
    df$Data <- df$Data %>% as.Date()
  df
}


#' Set recibos
#'
#' @param df dataframe: dataframe para salvar no BD
#' @param user character: nome do usuário
#'
#' @return List(nInserted, nMatched, nRemoved, nUpserted, writeErrors)
set_receipt <- function(df, user) {
  flog.info("Função | %s", as.character(sys.call()[1]))

  df <- df %>%
    mutate(
      CriadoEm  = Sys.time(),
      CriadoPor = user
    )
  # Connect to the database
  db = mongo(collection = "receipt",
             db = Sys.getenv("MONGO_DB"), url = Sys.getenv("MONGO_URL"))
  # Insert the data into the mongo collection as a data.frame
  lst <- db$insert(df)
}


#' Deleta (Atualiza) recibo com status de remoção
#'
#' @param id character: id do recibo
#' @param user character: nome do usuário
#'
#' @return List(modifiedCount, matchedCount, upsertedCount)
del_receipt <- function(id, user) {
  flog.info("Função | %s", as.character(sys.call()[1]))

  # Connect to the database
  db = mongo(collection = "receipt",
             db = Sys.getenv("MONGO_DB"), url = Sys.getenv("MONGO_URL"))
  # Read entries
  lst <- db$update(query  = paste0('{ "_id": { "$oid": "', id, '" },',
                                   '  "RemovidoEm": null }'),
                   update = paste0('{ "$set": { "RemovidoPor": "', user, '" },',
                                   '  "$currentDate": { "RemovidoEm": true } }'),
                   multiple = F)
}


#' Drop collection de recibos
#'
#' @return T
drop_receipt <- function() {
  flog.info("Função | %s", as.character(sys.call()[1]))

  # Connect to the database
  db = mongo(collection = "receipt",
             db = Sys.getenv("MONGO_DB"), url = Sys.getenv("MONGO_URL"))
  # Read entries
  bool <- db$remove(query = '{}')
}
