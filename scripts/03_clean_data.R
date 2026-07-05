# =====================================================
# NBA Rookie Success Model
# Author: Danny Thompson
# Script 03: Clean and Merge Data
# =====================================================


# 1. Helper Function ------------------------------------------------------

clean_name <- function(x) {
  x %>%
    str_to_lower() %>%
    str_replace_all("\\.", "") %>%
    str_replace_all(",", "") %>%
    str_replace_all(" jr$| sr$| ii$| iii$| iv$", "") %>%
    str_squish()
}


# 2. Clean College Data ---------------------------------------------------

college_clean <- college_data %>%
  rename(
    draft_pick_college = Pick,
    college_pts_total = `PTS...30`,
    three_pa = `3PA`,
    fga = FGA,
    fta = FTA,
    college_fg_pct = `FG%`,
    college_3p_pct = `3P%`,
    college_ft_pct = `FT%`,
    college_ts_pct = `TS%`,
    college_efg_pct = `eFG%`
  ) %>%
  select(
    Player,
    draft_year,
    draft_pick_college,
    `Draft Team`,
    `Draft College`,
    Season,
    Team,
    Pos,
    Class,
    G,
    GS,
    MP,
    college_pts_total,
    TRB,
    AST,
    STL,
    BLK,
    TOV,
    three_pa,
    fga,
    fta,
    college_fg_pct,
    college_3p_pct,
    college_ft_pct,
    college_ts_pct,
    college_efg_pct
  )


# 3. Merge Draft and College Data ----------------------------------------

master_data <- draft_data %>%
  left_join(
    college_clean,
    by = c("Player", "draft_year")
  )


# 4. Create Modeling Dataset ---------------------------------------------

model_data <- master_data %>%
  filter(!is.na(college_pts_total)) %>%
  mutate(
    success = if_else(WS >= 10, 1, 0),
    draft_pick = as.numeric(Pk),
    player_clean = clean_name(Player),
    
    PPG = college_pts_total / G.y,
    RPG = TRB / G.y,
    APG = AST / G.y,
    SPG = STL / G.y,
    BPG = BLK / G.y,
    TPG = TOV / G.y,
    
    AST_TO = if_else(TOV > 0, AST / TOV, NA_real_),
    three_pa_per_game = three_pa / G.y,
    ft_rate = fta / fga,
    ws_per_season = WS / Yrs
  ) %>%
  filter(!is.na(success))


# 5. Clean RealGM Physical Data ------------------------------------------

realgm_clean <- realgm_draft %>%
  mutate(
    height_inches = as.numeric(str_extract(Height, "^[0-9]+")) * 12 +
      as.numeric(str_extract(Height, "(?<=-)[0-9]+")),
    weight = as.numeric(Weight),
    draft_age = as.numeric(Age),
    draft_year = as.character(Year),
    draft_pick = as.numeric(Pick),
    player_clean = clean_name(Player)
  ) %>%
  select(
    player_clean,
    draft_year,
    draft_pick,
    height_inches,
    weight,
    draft_age
  )


# 6. Merge Physical Data --------------------------------------------------

analysis_data <- model_data %>%
  left_join(
    realgm_clean,
    by = c("player_clean", "draft_year", "draft_pick")
  ) %>%
  filter(
    !is.na(height_inches),
    !is.na(weight),
    !is.na(draft_age)
  )


# 7. Final Checks ---------------------------------------------------------

dim(master_data)
dim(model_data)
dim(analysis_data)

analysis_data %>%
  summarise(
    total_players = n(),
    avg_draft_pick = mean(draft_pick, na.rm = TRUE),
    success_count = sum(success == 1, na.rm = TRUE),
    non_success_count = sum(success == 0, na.rm = TRUE)
  )
