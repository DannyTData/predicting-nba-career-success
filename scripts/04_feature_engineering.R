# =====================================================
# NBA Rookie Success Model
# Author: Danny Thompson
# Script 04: Feature Engineering
# =====================================================


# 1. Basketball Features -----------------------------------------------

analysis_data <- analysis_data %>%
  mutate(
    age_adj_ppg = PPG / draft_age,
    age_adj_apg = APG / draft_age,
    age_adj_rpg = RPG / draft_age,
    
    scoring_efficiency = PPG * college_ts_pct,
    playmaking_score = APG * AST_TO,
    stocks = SPG + BPG,
    
    rebounding_share = RPG / PPG,
    offensive_versatility = PPG + APG,
    production_index = PPG + RPG + APG + SPG + BPG
  )


# 2. Data Quality Checks -----------------------------------------------

summary(
  analysis_data %>%
    select(
      age_adj_ppg,
      age_adj_apg,
      age_adj_rpg,
      scoring_efficiency,
      playmaking_score,
      stocks,
      rebounding_share,
      offensive_versatility,
      production_index
    )
)


# 3. Check for Missing Values ------------------------------------------

analysis_data %>%
  summarise(
    across(
      c(
        age_adj_ppg,
        age_adj_apg,
        age_adj_rpg,
        scoring_efficiency,
        playmaking_score,
        stocks,
        rebounding_share,
        offensive_versatility,
        production_index
      ),
      ~ sum(is.na(.))
    )
  )


# 4. Save Analysis Dataset ---------------------------------------------

saveRDS(
  analysis_data,
  "outputs/analysis_data.rds"
)
