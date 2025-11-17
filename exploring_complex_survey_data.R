library(pacman)
p_load(tidyverse, survey, srvyr, srvyrexploR, gt, gtsummary, censusapi)

# View American National Election Studies (ANES) 2020 Data Variables
anes_2020 %>%
  select(-matches("^V\\d")) %>%
  glimpse()

# View Residential Energy Consumption Survey Data Variables
recs_2020 %>%
  select(-matches("^NWEIGHT")) %>%
  glimpse()

# Retrieving Current Population Survey (CPS) data from March of 2020, when 
# ANES was run
cps_state_in <- getCensus(
  name = "cps/basic/mar",
  vintage = 2020,
  region = "state",
  vars = c(
    "HRMONTH", "HRYEAR4",
    "PRTAGE", "PRCITSHP", "PWSSWGT"
  ),
  key = Sys.getenv("CENSUS_KEY")
)

# Converting to tibble, and mutating to numeric
cps_state <- cps_state_in %>%
  as_tibble() %>%
  mutate(across(
    .cols = everything(),
    .fns = as.numeric
  ))

# Filtering for people over 18 with US citizenship
cps_narrow_resp <- cps_state %>%
  filter(
    PRTAGE >= 18,
    PRCITSHP %in% c(1:4)
  )

# Calculates the US Population using the person level weights
targetpop <- cps_narrow_resp %>%
  pull(PWSSWGT) %>%
  sum()

scales::comma(targetpop)

# Adjust the weighting variable using the population count we just created
anes_adjwgt <- anes_2020 %>%
  mutate(Weight = V200010b / sum(V200010b) * targetpop)

# Use survey documentation to input the correct elements of the design structure
anes_des <- anes_adjwgt %>%
  as_survey_design(
    weights = Weight,
    strata = V200010d,
    ids = V200010c,
    nest = TRUE
  )

anes_des