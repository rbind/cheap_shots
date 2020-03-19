require("dplyr")
require("tidyr")
require("stringr")
require("lubridate")
us_confirmed_long <- function(all_wide){
  # returns long dataframe with state level data for USA
  abbrv <- readr::read_csv(here::here("content/post/data/USA_state_abb.csv"))
  t1 <- all_wide %>% 
    rename(province = "Province/State", 
           country_region = "Country/Region") %>% 
    pivot_longer(-c(province, country_region, Lat, Long), 
                 names_to = "Date", values_to = "cumulative_cases") %>% 
    filter(country_region == "US") %>% 
    mutate(Date = mdy(Date)) %>% 
    #  mutate(Date = lubridate::mdy(Date) - lubridate::days(1)) %>% 
    arrange(province, Date)  %>% 
    # filter out state rows prior to march 8, and county rows after that. 
    # this is dropping virgin islands ... 
    filter(str_detect(province, ", ") & Date <= "2020-03-9" | 
             str_detect(province, ", ", negate = TRUE) & Date > "2020-03-9",
           str_detect(province, "Princess", negate = TRUE)) 
  # split off the county rows, match with state names and sum
  sum_counties <- t1 %>% 
    filter(str_detect(province, ", "),) %>% 
    separate(province, into = c("county", "ANSI_letter"), ", ") %>% 
    left_join(y = select(abbrv, ANSI_letter, name)) %>% 
    rename(province = name) %>% 
    group_by(province, Date) %>% 
    summarize(cumulative_cases = sum(cumulative_cases)) %>% 
    ungroup() %>% 
    mutate(country_region = "USA")
  states <- t1 %>% 
    filter(str_detect(province, ", ", negate = TRUE)) %>% 
    select(province, country_region, Date, cumulative_cases) %>% 
    mutate(country_region = "USA")
  bind_rows(sum_counties, states) %>% 
    arrange(province, Date)
    
}

other_confirmed_long <- function(all_wide, countries = c("Canada")){
  all_wide %>% 
    rename(province = "Province/State", 
           country_region = "Country/Region") %>% 
    pivot_longer(-c(province, country_region, Lat, Long), 
                 names_to = "Date", values_to = "cumulative_cases") %>% 
    filter(country_region %in% countries,
           # have to trap the rows with missing province (most other countries)
           # otherwise str_detect(province ...) is missing and dropped by filter()
           is.na(province) | str_detect(province, "Princess", negate = TRUE)) %>% 
    mutate(Date = mdy(Date)) %>% 
    select(-c("Lat", "Long"))
}