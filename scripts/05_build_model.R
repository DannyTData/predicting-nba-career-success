# =====================================================
# NBA Rookie Success Model
# Author: Danny Thompson
# Script 05: Build Final Prediction Model
# =====================================================

# 1. Load Analysis Data -----------------------------------------------

analysis_data <- readRDS("outputs/analysis_data.rds")


# 2. Build Final Logistic Regression Model -----------------------------

rookie_model <- glm(
  success ~
    draft_pick +
    draft_age +
    height_inches +
    weight +
    PPG +
    RPG +
    APG +
    SPG +
    BPG +
    AST_TO +
    college_ts_pct,
  
  data = analysis_data,
  family = binomial
)


# 3. Review Model ------------------------------------------------------

summary(rookie_model)


# 4. Create Predictions ------------------------------------------------

analysis_data <- analysis_data %>%
  mutate(
    
    probability = predict(
      rookie_model,
      type = "response"
    ),
    
    NBA_Success_Score = round(
      probability * 100,
      1
    ),
    
    predicted_success =
      if_else(
        probability >= .50,
        1,
        0
      ),
    
    prediction_result =
      if_else(
        predicted_success == success,
        "Correct",
        "Incorrect"
      )
  )


# 5. Create Final Results Table ---------------------------------------

model_results <- analysis_data %>%
  select(
    
    Player,
    
    draft_year,
    
    draft_pick,
    
    NBA_Success_Score,
    
    probability,
    
    predicted_success,
    
    success,
    
    WS,
    
    Yrs,
    
    ws_per_season,
    
    PPG,
    
    RPG,
    
    APG,
    
    SPG,
    
    BPG,
    
    AST_TO,
    
    college_ts_pct,
    
    draft_age,
    
    height_inches,
    
    weight,
    
    Pos,
    
    Class,
    
    prediction_result
    
  ) %>%
  arrange(desc(NBA_Success_Score))


# 6. Save Objects ------------------------------------------------------

saveRDS(
  rookie_model,
  "outputs/rookie_model.rds"
)

saveRDS(
  model_results,
  "outputs/model_results.rds"
)


# 7. Quick Checks ------------------------------------------------------

summary(rookie_model)

head(model_results)

View(model_results)
