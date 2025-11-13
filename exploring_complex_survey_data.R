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