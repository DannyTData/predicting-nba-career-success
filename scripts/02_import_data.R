# =====================================================
# NBA Rookie Success Model
# Author: Danny Thompson
# Script 02: Import Data
# =====================================================


# 1. Draft Files ----------------------------------------------------------

draft_files <- list.files(
  path = "data",
  pattern = "^[0-9]{4}\\.xls$",
  full.names = TRUE
)

draft_data <- draft_files %>%
  map_dfr(~ read_excel(.x, skip = 1) %>%
            mutate(draft_year = str_extract(.x, "[0-9]{4}")))


# 2. College Files --------------------------------------------------------

college_files <- list.files(
  path = "data",
  pattern = "^[0-9]{4} college\\.xls$",
  full.names = TRUE
)

college_data <- college_files %>%
  map_dfr(~ read_excel(.x) %>%
            mutate(draft_year = str_extract(.x, "[0-9]{4}")))


# 3. RealGM Physical Data -------------------------------------------------

realgm_draft <- read_excel("data/realgm_draft.xls")


# 4. Check Imports --------------------------------------------------------

dim(draft_data)
dim(college_data)
dim(realgm_draft)

names(draft_data)
names(college_data)
names(realgm_draft)
