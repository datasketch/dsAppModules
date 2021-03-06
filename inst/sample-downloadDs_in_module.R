library(shiny)
library(dsmodules)
library(shinyinvoer)
library(shinypanels)
library(dspins)
library(reactable)
library(hgchmagic)

# in ui: "download_server-download_server-hello"
# in server: "download_example_module-download_example_module-download_server-download_example_module-download_server-hello"

user_name <- "brandon"
org_name <- "test"
plan <- "pro"

downloadExampleUI <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput(ns("download"))
  )
}

downloadExampleServer <- function(id, r) {
  moduleServer(
    id,
    function(input, output, session) {
      ns <- NS(id)

      output$download <- renderUI({
        downloadDsUI(ns("download_server"),
                     plan = plan,
                     display = "buttons",
                     modalFormatChoices = c("HTML" = "html", "PNG" = "png"),
                     dropdownLabel = "Download",
                     max_inputs_first_column = 4,
                     formats = c("html", "jpeg", "pdf", "png"))

      })


      observe({
        req(r$element)
        downloadDsServer(id = "download_server",
                         element = reactive(r$element),
                         formats = c("html", "jpeg", "pdf", "png"),
                         type = "dsviz",
                         displayLinks = TRUE,
                         user_name = user_name,
                         org_name = org_name,
                         page_title = "some page title")
      })

    }
  )
}



ui <- panelsPage(shinyjs::useShinyjs(),
                 shinyCopy2clipboard::use_copy(),
                 panel(title = "Examples",
                       body = div(h3("Ds download module called from shiny module"),
                                  br(),
                                  br(),
                                  downloadExampleUI("download_example_module")
                       )),
                 panel(title = "E")
)

server <- function(input, output, session) {


  r <- reactiveValues()

  element <- reactive({
    reactable::reactable(data.frame(a = 1:3, b = "r"))
    #hgchmagic::hgch_bar_Cat(sample_data("Cat"))
  })

  observe({
    r$element <- element()
  })


  # Call download module
  downloadExampleServer("download_example_module", r = r)

}


shinyApp(ui, server)
