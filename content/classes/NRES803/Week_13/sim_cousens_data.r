## prep Cousens data
## tables 1 and 2 provide means
## there were 6 replicates
## RSS for simplest models were 
## Response    | Wheat | Barley
## Jun biomass | 0.175 | .63
## Aug biomass | 1.337 | 3.388
## Yield       | .173  | .695
## assume these are variances around each mean
## simulate from a t distribution with 24*6 - 2 df, multiply by sd and 
## add variance? Don't bother, just use normal deviates
library(tidyverse)

cousens85 <- read_csv("data/cousens_1985_tab_1_2.csv")
cousensRSS <- read_csv("data/cousens_1985_RSS.csv")

# put the means and variances together
cousensSim <- gather(cousens85, key=variable, value=mass, -(1:2)) %>%
  left_join(cousensRSS)

# a new function to take a row of cousensSim and return appropriate 
# random numbers.
myfunc <- function(dfrow, reps=6){
  # method of moments estimates from wikipedia page
  E_X = dfrow$mass
  VAR_X = dfrow$RSS
  mu = log(E_X^2 / sqrt(VAR_X + E_X^2))
  sigma2 = log(1 + VAR_X / E_X^2)
  samples <- suppressWarnings(rnorm(reps, 
                                    mean=mu,
                                    sd=sqrt(sigma2)))
  if (any(is.nan(samples))){
    samples <- rep(NA_real_, reps)
  }
  
  result <- data.frame(rep=1:reps,
                       massrep = samples)
  return(result)
}

# should set seed here ... 
set.seed(987304)
# might need to install purrrlyr - extract each row of cousensSim
# and pass to myfunc, collate the result by rows.
cousensSim2 <- purrrlyr::by_row(cousensSim, myfunc, .collate="rows")


# filter(cousensSim2, !grepl("seedlings", variable)) %>%
#   mutate(massrep = exp(massrep)) %>%
#   ggplot(aes(x=wheat_sr, y=massrep, col=barley_sr)) + 
#   geom_point() + 
#   facet_wrap(~variable, scales="free")

## turn it into something like a real dataset
## discarding mean information etc. 
## keep sr, rep variables

cousensSim3 <- cousensSim2 %>%
  select(contains("sr"), variable, contains("rep")) %>%
  filter(!is.na(massrep)) %>%
  mutate(massrep = exp(massrep)) %>%
  spread(variable, massrep)

write.csv(cousensSim3, file = "data/cousenssim.csv",
          row.names = FALSE)
