# =====================================================
# NBA Rookie Success Model
# Author: Danny Thompson
# Script 08: Visualizations
# =====================================================

library(dplyr)
library(ggplot2)
library(readr)

# 1. Load Results --------------------------------------------------------

model_results <- readRDS("outputs/data/model_results.rds")

if (!dir.exists("outputs/figures")) {
  dir.create("outputs/figures")
}


# 2. Top 20 NBA Success Scores ------------------------------------------

top_20 <- model_results %>%
  arrange(desc(NBA_Success_Score)) %>%
  slice_head(n = 20)

ggplot(top_20, aes(x = reorder(Player, NBA_Success_Score),
                   y = NBA_Success_Score)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 20 NBA Success Scores",
    x = "Player",
    y = "NBA Success Score"
  )

ggsave(
  "outputs/figures/top_20_success_scores.png",
  width = 10,
  height = 7
)


# 3. Draft Pick vs NBA Success Score -------------------------------------

ggplot(model_results, aes(x = draft_pick, y = NBA_Success_Score)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Draft Pick vs NBA Success Score",
    x = "Draft Pick",
    y = "NBA Success Score"
  )

ggsave(
  "outputs/figures/draft_pick_vs_success_score.png",
  width = 9,
  height = 6
)


# 4. Probability vs Career Win Shares ------------------------------------

ggplot(model_results, aes(x = probability, y = WS)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Predicted Probability vs Career Win Shares",
    x = "Predicted Probability",
    y = "Career Win Shares"
  )

ggsave(
  "outputs/figures/probability_vs_win_shares.png",
  width = 9,
  height = 6
)


# 5. Distribution of NBA Success Scores ----------------------------------

ggplot(model_results, aes(x = NBA_Success_Score)) +
  geom_histogram(bins = 25) +
  labs(
    title = "Distribution of NBA Success Scores",
    x = "NBA Success Score",
    y = "Number of Players"
  )

ggsave(
  "outputs/figures/success_score_distribution.png",
  width = 9,
  height = 6
)


# 6. Biggest Model Misses ------------------------------------------------

biggest_misses <- model_results %>%
  mutate(error = abs(success - probability)) %>%
  arrange(desc(error)) %>%
  slice_head(n = 20)

ggplot(biggest_misses, aes(x = reorder(Player, error), y = error)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Biggest Model Misses",
    x = "Player",
    y = "Prediction Error"
  )

ggsave(
  "outputs/figures/biggest_model_misses.png",
  width = 10,
  height = 7
)


# 7. Confirm Outputs -----------------------------------------------------

list.files("outputs/figures")