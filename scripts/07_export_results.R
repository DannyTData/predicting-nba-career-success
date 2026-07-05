# =====================================================
# NBA Rookie Success Model
# Author: Danny Thompson
# Script 07: Export Final Results
# =====================================================

library(dplyr)
library(writexl)
library(broom)


# 1. Load Objects --------------------------------------------------------

model_results <- readRDS("outputs/data/model_results.rds")
rookie_model <- readRDS("outputs/models/rookie_model.rds")


# 2. Top Prospects -------------------------------------------------------

top_25_prospects <- model_results %>%
  arrange(desc(NBA_Success_Score)) %>%
  slice_head(n = 25)


# 3. Biggest Misses ------------------------------------------------------

biggest_misses <- model_results %>%
  mutate(
    error = abs(success - probability)
  ) %>%
  arrange(desc(error)) %>%
  slice_head(n = 25)


# 4. False Positives -----------------------------------------------------

false_positives <- model_results %>%
  filter(predicted_success == 1, success == 0) %>%
  arrange(desc(probability))


# 5. False Negatives -----------------------------------------------------

false_negatives <- model_results %>%
  filter(predicted_success == 0, success == 1) %>%
  arrange(probability)


# 6. Model Coefficients --------------------------------------------------

model_coefficients <- tidy(rookie_model) %>%
  arrange(p.value)


# 7. Model Metrics -------------------------------------------------------

model_metrics <- tibble::tibble(
  Metric = c(
    "Accuracy",
    "Precision",
    "Recall",
    "ROC AUC",
    "True Positives",
    "True Negatives",
    "False Positives",
    "False Negatives"
  ),
  Value = c(
    0.733,
    0.709,
    0.709,
    0.791,
    124,
    156,
    51,
    51
  )
)


# 8. Export Workbook -----------------------------------------------------

if (!dir.exists("outputs")) {
  dir.create("outputs")
}

write_xlsx(
  list(
    Player_Predictions = model_results,
    Top_25_Prospects = top_25_prospects,
    Biggest_Misses = biggest_misses,
    False_Positives = false_positives,
    False_Negatives = false_negatives,
    Model_Coefficients = model_coefficients,
    Model_Metrics = model_metrics
  ),
  "outputs/reports/NBA_Rookie_Model_Final_Workbook.xlsx"
)


# 9. Confirm Export ------------------------------------------------------

list.files("outputs/reports")
