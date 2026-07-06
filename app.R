library(shiny)
library(dplyr)
library(DT)

model_results <- readRDS("outputs/data/model_results.rds")

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { background-color: #f5f7fa; font-family: Arial, sans-serif; }
      .title { background-color: #0B1F3A; color: white; padding: 25px; border-radius: 10px; margin-bottom: 20px; }
      .card { background-color: white; padding: 20px; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,.12); margin-bottom: 20px; }
      .metric { font-size: 34px; font-weight: bold; color: #0B1F3A; }
      .label { color: #666; font-size: 14px; }
      .reason { font-size: 16px; line-height: 1.8; }
    "))
  ),
  
  div(class = "title",
      h1("🏀 Beyond the Box Score"),
      h4("Predicting NBA Career Success Using Pre-Draft College Performance")
  ),
  
  tabsetPanel(
    
    tabPanel(
      "Overview",
      fluidRow(
        column(3, div(class = "card", div(class = "label", "Players"), div(class = "metric", nrow(model_results)))),
        column(3, div(class = "card", div(class = "label", "Accuracy"), div(class = "metric", "73.3%"))),
        column(3, div(class = "card", div(class = "label", "ROC AUC"), div(class = "metric", "0.791"))),
        column(3, div(class = "card", div(class = "label", "Model Variables"), div(class = "metric", "11")))
      ),
      
      div(class = "card",
          h3("Project Overview"),
          p("This dashboard explores an NBA Rookie Success Model built using pre-draft information from NBA draft picks between 2012 and 2020."),
          p("The model estimates the probability that a player becomes a successful NBA player, defined as reaching at least 10 Career Win Shares."),
          p("Inputs include draft position, draft age, height, weight, college production, assist-to-turnover ratio, and true shooting percentage.")
      ),
      div(class = "card",
          p("Created by Danny Thompson"),
          p("Basketball Analytics Portfolio Project"),
          p("GitHub: DannyTData")
      )
    ),
    
    tabPanel(
      "Player Lookup",
      sidebarLayout(
        sidebarPanel(
          selectInput(
            "player",
            "Select Player:",
            choices = sort(unique(model_results$Player))
          )
        ),
        
        mainPanel(
          uiOutput("player_cards"),
          div(class = "card",
              h3("Why Did the Model Like This Player?"),
              htmlOutput("model_explanation")
          )
        )
      )
    ),
    
    tabPanel(
      "Visualizations",
      div(class = "card",
          h3("Top 20 NBA Success Scores"),
          img(src = "top_20_success_scores.png", width = "100%")
      ),
      div(class = "card",
          h3("Draft Pick vs NBA Success Score"),
          img(src = "draft_pick_vs_success_score.png", width = "100%")
      ),
      div(class = "card",
          h3("Predicted Probability vs Career Win Shares"),
          img(src = "probability_vs_win_shares.png", width = "100%")
      ),
      div(class = "card",
          h3("NBA Success Score Distribution"),
          img(src = "success_score_distribution.png", width = "100%")
      ),
      div(class = "card",
          h3("Biggest Model Misses"),
          img(src = "biggest_model_misses.png", width = "100%")
      )
    ),
    
    tabPanel(
      "Leaderboard",
      div(class = "card",
          h3("Full Player Leaderboard"),
          DTOutput("leaderboard")
      )
    ),
    
    tabPanel(
      "About Model",
      div(class = "card",
          h3("Research Question"),
          p("Can pre-draft college performance, draft position, and physical profile data predict NBA career success?")
      ),
      
      div(class = "card",
          h3("Final Model"),
          p("The final model uses logistic regression to estimate the probability of NBA success."),
          tags$ul(
            tags$li("Draft Pick"),
            tags$li("Draft Age"),
            tags$li("Height"),
            tags$li("Weight"),
            tags$li("PPG, RPG, APG, SPG, BPG"),
            tags$li("Assist-to-Turnover Ratio"),
            tags$li("College True Shooting Percentage")
          )
      ),
      
      div(class = "card",
          h3("Model Performance"),
          tags$table(
            class = "table",
            tags$tr(tags$th("Metric"), tags$th("Result")),
            tags$tr(tags$td("Accuracy"), tags$td("73.3%")),
            tags$tr(tags$td("Precision"), tags$td("70.9%")),
            tags$tr(tags$td("Recall"), tags$td("70.9%")),
            tags$tr(tags$td("ROC AUC"), tags$td("0.791")),
            tags$tr(tags$td("AIC"), tags$td("444.69"))
          )
      ),
      
      div(class = "card",
          h3("Limitations"),
          p("The model only uses information available before the NBA Draft. It does not account for injuries, team fit, coaching, player development, role changes, or off-court factors.")
      )
    )
  )
)

server <- function(input, output) {
  
  selected_player <- reactive({
    model_results %>%
      filter(Player == input$player)
  })
  
  output$player_cards <- renderUI({
    p <- selected_player()
    
    fluidRow(
      column(4,
             div(class = "card",
                 div(class = "label", "NBA Success Score"),
                 div(class = "metric", p$NBA_Success_Score)
             )
      ),
      column(4,
             div(class = "card",
                 div(class = "label", "Success Probability"),
                 div(class = "metric", paste0(round(p$probability * 100, 1), "%"))
             )
      ),
      column(4,
             div(class = "card",
                 div(class = "label", "Career Win Shares"),
                 div(class = "metric", round(p$WS, 1))
             )
      ),
      
      column(12,
             div(class = "card",
                 h2(p$Player),
                 p(strong("Draft Year: "), p$draft_year),
                 p(strong("Draft Pick: "), p$draft_pick),
                 p(strong("Years Played: "), p$Yrs),
                 h4("College Profile"),
                 p(strong("PPG: "), round(p$PPG, 1)),
                 p(strong("RPG: "), round(p$RPG, 1)),
                 p(strong("APG: "), round(p$APG, 1)),
                 p(strong("AST/TO: "), round(p$AST_TO, 2)),
                 p(strong("College TS%: "), paste0(round(p$college_ts_pct * 100, 1), "%"))
             )
      )
    )
  })
  
  output$model_explanation <- renderUI({
    p <- selected_player()
    reasons <- c()
    
    if (p$draft_pick <= 10) {
      reasons <- c(reasons, "✅ Selected in the Top 10 of the NBA Draft")
    }
    
    if (p$college_ts_pct >= 0.58) {
      reasons <- c(reasons, "✅ Efficient college scorer based on True Shooting Percentage")
    }
    
    if (p$AST_TO >= 2) {
      reasons <- c(reasons, "✅ Strong assist-to-turnover ratio")
    }
    
    if (p$PPG >= 18) {
      reasons <- c(reasons, "✅ High college scoring production")
    }
    
    if (p$RPG >= 7) {
      reasons <- c(reasons, "✅ Strong rebounding profile")
    }
    
    if (p$BPG >= 1.5) {
      reasons <- c(reasons, "✅ Strong shot-blocking production")
    }
    
    if (length(reasons) == 0) {
      reasons <- c(
        reasons,
        "This player did not strongly stand out in the model's primary input variables."
      )
    }
    
    HTML(paste(paste0("<div class='reason'>", reasons, "</div>"), collapse = ""))
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