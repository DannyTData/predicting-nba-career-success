library(shiny)
library(dplyr)
library(DT)

model_results <- readRDS("outputs/data/model_results.rds")

ui <- fluidPage(
  titlePanel("NBA Rookie Success Model"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "player",
        "Select Player:",
        choices = sort(unique(model_results$Player))
      )
    ),
    
    mainPanel(
      h3("Player Projection"),
      tableOutput("player_summary"),
      
      h3("Leaderboard"),
      DTOutput("leaderboard")
    )
  )
)

server <- function(input, output) {
  
  selected_player <- reactive({
    model_results %>%
      filter(Player == input$player)
  })
  
  output$player_summary <- renderTable({
    selected_player() %>%
      select(
        Player,
        draft_year,
        draft_pick,
        NBA_Success_Score,
        Probability = probability,
        WS,
        Yrs,
        PPG,
        RPG,
        APG,
        AST_TO,
        college_ts_pct
      ) %>%
      mutate(
        Probability = paste0(round(Probability * 100, 1), "%")
      )
  })
  
  output$leaderboard <- renderDT({
    model_results %>%
      select(
        Player,
        draft_year,
        draft_pick,
        NBA_Success_Score,
        Probability = probability,
        WS,
        success
      ) %>%
      mutate(
        Probability = paste0(round(Probability * 100, 1), "%")
      ) %>%
      arrange(desc(NBA_Success_Score))
  })
}

shinyApp(ui = ui, server = server)


