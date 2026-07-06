# =====================================================
# NBA Rookie Success Model
# Script 09: Build No-Draft-Pick Model
# =====================================================

library(dplyr)
library(writexl)
library(broom)
library(yardstick)

analysis_data <- readRDS("outputs/data/analysis_data.rds")

rookie_model_no_pick <- glm(
  success ~
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

analysis_data_no_pick <- analysis_data %>%
  mutate(
    probability_no_pick = predict(
      rookie_model_no_pick,
      type = "response"
    ),
    NBA_Success_Score_No_Pick = round(probability_no_pick * 100, 1),
    predicted_success_no_pick = if_else(probability_no_pick >= .50, 1, 0),
    success_factor = factor(
      if_else(success == 1, "Success", "Not Successful"),
      levels = c("Success", "Not Successful")
    ),
    prediction_factor_no_pick = factor(
      if_else(predicted_success_no_pick == 1, "Success", "Not Successful"),
      levels = c("Success", "Not Successful")
    )
  )

model_metrics_no_pick <- tibble::tibble(
  Metric = c(
    "Accuracy",
    "Precision",
    "Recall",
    "ROC AUC",
    "AIC"
  ),
  Value = c(
    accuracy(
      analysis_data_no_pick,
      truth = success_factor,
      estimate = prediction_factor_no_pick
    )$.estimate,
    precision(
      analysis_data_no_pick,
      truth = success_factor,
      estimate = prediction_factor_no_pick
    )$.estimate,
    recall(
      analysis_data_no_pick,
      truth = success_factor,
      estimate = prediction_factor_no_pick
    )$.estimate,
    roc_auc(
      analysis_data_no_pick,
      truth = success_factor,
      probability_no_pick
    )$.estimate,
    AIC(rookie_model_no_pick)
  )
)

dir.create("outputs/models", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

saveRDS(
  rookie_model_no_pick,
  "outputs/models/rookie_model_no_pick.rds"
)

write_xlsx(
  list(
    Model_Metrics_No_Pick = model_metrics_no_pick,
    Model_Coefficients_No_Pick = tidy(rookie_model_no_pick)
  ),
  "outputs/tables/no_pick_model_review.xlsx"
)

summary(rookie_model_no_pick)
model_metrics_no_pick