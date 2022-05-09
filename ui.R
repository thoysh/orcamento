## ui.R ##
# Define a interface de usuário (UI) do Shiny web app

# Shiny libraries ----
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(DT)
library(shinyjs)
library(shinyalert)
library(shinycssloaders)
# DB libraries ----
library(mongolite)
# Common libraries ----
library(shinymanager)
library(tidyverse)
library(stringr)
library(lubridate)
# Log libraries ----
library(futile.logger)
# Other libraries ----
library(jsonlite)
library(readxl)
library(writexl)

# Faz source de todos os arquivos .R
list.files("R", pattern = "\\.R$", full.names = T, recursive = T) %>%
  walk(~source(.x, encoding = "UTF-8"))


# Define o UI header ----
mainHeader <- dashboardHeader(
  title = "J&M"
)


# Define UI sidebar ----
mainSidebar <- dashboardSidebar(collapsed = T,
  useShinyjs(),    # Setup shinyjs
  useShinyalert(), # Setup shinyalert
  sidebarMenu(menuItem("Recibos",   icon = icon("fa-receipt"), tabName = "tabItem_receipt"),
              menuItem("Histórico", icon = icon("fa-database"), tabName = "tabItem_data")
  )
)


# Define UI body ----
mainBody <- dashboardBody(
  tags$head(
    tags$style(HTML(".shiny-output-error-validation { color: #ff0000; font-weight: bold; }"))
  ),

  tabItems(
    tabItem("tabItem_receipt", receiptUI("receipt")),
    tabItem("tabItem_data", dataUI("data"))
  )
)


# Define a UI ----
ui <- dashboardPage(
    mainHeader,
    mainSidebar,
    mainBody,
    skin = "blue"
)
