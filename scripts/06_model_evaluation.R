# =====================================================
# NBA Rookie Success Model
# Author: Danny Thompson
# Script 06: Model Evaluation
# =====================================================

library(dplyr)
library(yardstick)
library(pROC)

# 1. Load Results --------------------------------------------------------

model_results <- readRDS("outputs/model_results.rds")


# 2. Prepare Evaluation Data --------------------------------------------

eval_data <- model_results %>%
  mutate(
    success_factor = factor(
      if_else(success == 1, "Success", "Not Successful"),
      levels = c("Success", "Not Successful")
    ),
    prediction_factor = factor(
      if_else(predicted_success == 1, "Success", "Not Successful"),
      levels = c("Success", "Not Successful")
    )
  )


# 3. Confusion Matrix ----------------------------------------------------

conf_mat(eval_data, truth = success_factor, estimate = prediction_factor)


# 4. Accuracy ------------------------------------------------------------

accuracy(eval_data, truth = success_factor, estimate = prediction_factor)


# 5. Precision -----------------------------------------------------------

precision(eval_data, truth = success_factor, estimate = prediction_factor)


# 6. Recall --------------------------------------------------------------

recall(eval_data, truth = success_factor, estimate = prediction_factor)


# 7. ROC AUC -------------------------------------------------------------

roc_auc(
  eval_data,
  truth = success_factor,
  probability
)


# 8. ROC Curve -----------------------------------------------------------

roc_curve <- roc(
  response = eval_data$success,
  predictor = eval_data$probability
)

plot(
  roc_curve,
  main = "NBA Rookie Success Model ROC Curve"
)


# 9. Biggest Misses ------------------------------------------------------

biggest_misses <- eval_data %>%
  mutate(
    error = abs(success - probability)
  ) %>%
  arrange(desc(error)) %>%
  select(
    Player,
    draft_year,
    draft_pick,
    NBA_Success_Score,
    probability,
    WS,
    success,
    predicted_success,
    prediction_result,
    error
  )

head(biggest_misses, 20)