require("dplyr")
require("tidyr")
require("stringr")
require("lubridate")
us_wide2long <- function(all_wide, usa_abbr = NULL){
  # returns long dataframe with state level data for USA
  abbrv <- readr::read_csv(here::here("content/post/data/USA_state_abb.csv"))
  if (is.null(usa_abbr)) stop("Must provide the appropriate abbreviation for USA for this data")
  t1 <- all_wide %>% 
    # rename(province = "Province/State", 
    #        country_region = "Country/Region") %>% 
    pivot_longer(-c(Region, Country), 
                 names_to = "Date", values_to = "cumulative_cases") %>% 
    filter(Country == usa_abbr) %>% 
    mutate(Date = ymd(Date)) %>% 
    #  mutate(Date = lubridate::mdy(Date) - lubridate::days(1)) %>% 
    arrange(Region, Date)  %>% 
    # filter out state rows prior to march 10, and county rows after that. 
    # this is dropping virgin islands ... 
    filter(str_detect(Region, ", ") & Date <= "2020-03-9" | 
             str_detect(Region, ", ", negate = TRUE) & Date > "2020-03-9",
           str_detect(Region, "Princess", negate = TRUE)) 
  # split off the county rows, match with state names and sum
  sum_counties <- t1 %>% 
    filter(str_detect(Region, ", "),) %>% 
    separate(Region, into = c("county", "ANSI_letter"), ", ") %>% 
    left_join(y = select(abbrv, ANSI_letter, name)) %>% 
    rename(Region = name) %>% 
    group_by(Region, Date) %>% 
    summarize(cumulative_cases = sum(cumulative_cases, na.rm = TRUE)) %>% 
    ungroup() %>% 
    mutate(Country = usa_abbr)
  states <- t1 %>% 
    filter(str_detect(Region, ", ", negate = TRUE)) %>% 
    select(Region, Country, Date, cumulative_cases) %>% 
    mutate(Country = usa_abbr)
  bind_rows(sum_counties, states) %>% 
    arrange(Region, Date)
    
}

other_wide2long <- function(all_wide, countries = c("Canada")){
  all_wide %>% 
    # rename(province = "Province/State", 
    #        country_region = "Country/Region") %>% 
    pivot_longer(-c(Region, Country), 
                 names_to = "Date", values_to = "cumulative_cases") %>% 
    filter(Country %in% countries,
           # have to trap the rows with missing province (most other countries)
           # otherwise str_detect(province ...) is missing and dropped by filter()
           #is.na(Region) | 
             str_detect(Region, "Princess", negate = TRUE) , 
             str_detect(Region, "Recovered", negate = TRUE),
             str_detect(Region, ", ", negate = TRUE)) %>% 
    mutate(Date = ymd(Date)) 
#    select(-c("Lat", "Long"))
}