require("tidyverse")
require("lubridate")
require("broom")

#' Plot of active case growth by country/region
#'
#' @param x dataframe with one row per date/region combination, and confirmed, deaths, recoveries variables 
#' @param country_data dataframe with one row per country or region
#'
#' @return list of modified 
#' @export
#'
plot_active_case_growth <- function(x, country_data, case_cutoff = 20, min_n = 5, 
                                    model_window = c(0,13), predict_window = c(min_n+1, 28)){
    data_by_region <- x %>% 
    group_by(Region) %>% 
    mutate(incident_cases = c(0, diff(confirmed)),
           incident_deaths = c(0, diff(deaths)),
           active = confirmed - deaths - recoveries) %>% 
    left_join(country_data, by = c("Country", "Region")) %>% 
    mutate(icpc = incident_cases / popn / 10,
           arpc = active / popn / 10,
           group = Region,
           date_cutoff = Date[min(which(confirmed >= case_cutoff))],
           day = as.numeric(Date - date_cutoff),
           samplesize = max(day)) %>% 
    ungroup() %>% 
    filter(!is.na(date_cutoff),
           samplesize > min_n) # remove regions with less than 20 cases total or fewer than 5 days.
  if(nrow(data_by_region) > min_n){
    # recreate this adding date_cutoff  
    country_data <- data_by_region %>% 
      group_by(Region) %>% 
      summarize(date_cutoff = first(date_cutoff),
                popn = first(popn),
                icu_beds = first(icu_beds),
                maxday = max(day)) %>% 
      mutate(max_icu_beds = icu_beds * 20,
             start_day = min(c(model_window, predict_window)),
             end_day =  max(c(model_window, predict_window, maxday)))
    
    all_models <- data_by_region %>% 
      mutate(log10_ar = log10(active)) %>% 
      filter(day <= model_window[2], day >= model_window[1]) %>%  # model using first 2 weeks of data
      group_by(Region) %>% 
      nest() %>% 
      mutate(model = map(data, ~lm(log10_ar~day, data = .)))
    
    all_fit <- all_models %>% 
      mutate(fit = map(model, augment, se_fit = TRUE),
             fit = map(fit, select, -c("log10_ar","day"))) %>% 
      select(-model) %>% 
      unnest(cols = c("data","fit")) %>% 
      mutate(fit = 10^.fitted,
             lcl = 10^(.fitted - .se.fit * qt(0.975, df = 10)),
             ucl = 10^(.fitted + .se.fit * qt(0.975, df = 10)),
             fitpc = fit / popn / 10,
             lclpc = lcl / popn / 10,
             uclpc = ucl / popn / 10)
    
    all_predicted <- cross_df(list(Region = pull(country_data, Region), 
                                   day = predict_window[1]:predict_window[2])) %>% 
      group_by(Region) %>% 
      nest() %>% 
      left_join(select(all_models, Region, model), by="Region") %>% 
      mutate(predicted = map2(model, data, ~augment(.x, newdata = .y, se_fit = TRUE)),
             sigma = map_dbl(model, ~summary(.x)$sigma)) %>% 
      select(-c(model,data)) %>% 
      unnest(cols = predicted) %>% 
      ungroup() %>% 
      left_join(country_data, by = "Region") %>% 
      filter(day > pmin(maxday+1, max(model_window))) %>% 
      mutate(
        Date = date_cutoff + day,
        Region = Region, # use factor to modify plot order
        fit = 10^.fitted,
        pred_var = sigma^2 + .se.fit^2,
        lpl = 10^(.fitted - sqrt(pred_var)*qt(0.975, df = 10)),
        upl = 10^(.fitted + sqrt(pred_var)*qt(0.975, df = 10)),
        fitpc = fit / popn / 10,
        lplpc = lpl / popn / 10,
        uplpc = upl / popn / 10)
    
    doubling_times <- all_models %>% 
      mutate(estimates = map(model, tidy)) %>% 
      unnest(cols = estimates) %>%  # produces 2 rows per country, (intercept) and day100
      filter(term == "day") %>% 
      select(Region, estimate, std.error) %>% 
      mutate(var_b = std.error^2,
             t = log10(2) / estimate,
             var_t = var_b * log10(2)^2 / estimate^4,
             lcl_t = t - sqrt(var_t)*qt(0.975, 12),
             ucl_t = t + sqrt(var_t)*qt(0.975, 12),
             label = sprintf("%.2f (%.2f, %.2f)", t, lcl_t, ucl_t))
    
    facet_labels <- doubling_times %>% 
      mutate(label = paste0(Region," doubling time (95% CL): ", label)) %>% 
      pull(label)
    names(facet_labels) <- pull(doubling_times, Region)
    .plot <- ggplot(data = filter(data_by_region, day >= 0),
                    mapping = aes(x = day)) + 
      geom_point(mapping = aes(y = arpc, color = Region)) + 
      facet_wrap(~Region, dir="v", labeller = labeller(Region = facet_labels)) + 
      scale_y_log10() + 
      theme(legend.position = "none",
            legend.title = element_blank()) + 
      geom_line(data = all_fit,
                mapping = aes(y = fitpc, color = Region),
                size = 1.25) +
      geom_ribbon(data = all_fit,
                  mapping = aes(ymin = lclpc, ymax = uclpc),
                  alpha = 0.2) +
      geom_line(data = all_predicted,
                mapping = aes(y = fitpc, color = Region),
                linetype = 2) +
      geom_ribbon(data = all_predicted,
                  mapping = aes(ymin = lplpc, ymax = uplpc),
                  alpha = 0.2)  +
      geom_rect(data = country_data,
                mapping = aes(x = start_day, xmin = start_day, xmax = end_day, ymin = icu_beds, ymax = icu_beds * 20), 
                fill = "red", alpha = 0.2) +
      labs(y = "Active cases per 100,000 population", 
           title = paste0("Active cases by days since ", case_cutoff, "th case"),
           x = paste0("Days since ", case_cutoff, "th case"),
           subtitle = "Solid line: exponential model; Dashed line: forecast cases with 95% prediction intervals.",
           caption = paste("Source data: https://coviddata.github.io/coviddata/ downloaded ",
                           format(file.mtime(savefilename), usetz = TRUE),
                           "\n Unofficial, not peer reviewed results.",
                           "\n Copyright Andrew Tyre 2020. Distributed with MIT License."))   +
      geom_text(data = slice(country_data, 1),
                mapping = aes(y = icu_beds),
                x = 0, #ymd("2020-03-01"),
                label = "# ICU beds / 100K",
                size = 2.5, hjust = "left", vjust = "bottom") +
      geom_text(data = slice(country_data, 1),
                mapping = aes(y = 20*icu_beds),
                x = 0, #ymd("2020-03-01"),
                label = "# 20 times ICU beds / 100K",
                size = 2.5, hjust = "left", vjust = "top")
    
  } else {
    .plot = ggplot() # empty ggplot object
    all_models <- all_fit <- all_predicted <- doubling_times <- NULL
  }
    
  list(.plot = .plot, data = data_by_region, models = all_models, 
       fits = all_fit, predictions = all_predicted, doubling_times = doubling_times)
}

#' Plot of active case growth by country/region
#'
#' @param x dataframe with one row per date/region combination, and confirmed, deaths, recoveries variables 

#'
#' @return list of modified 
#' @export
#'
plot_nytimes_counties <- function(x, county_data, 
                                  case_cutoff = 20, min_n = 5, 
                                    model_window = c(0,13), predict_window = c(min_n+1, 28),
                                  exclude = ""){
  data_by_county <- x %>% 
    group_by(county) %>% 
    mutate(incident_cases = c(0, diff(cases)),
           incident_deaths = c(0, diff(deaths)),
           active = cases - deaths) %>% 
    left_join(county_data, by = "county") %>% 
    mutate(icpc = incident_cases / POP / 10,
           arpc = active / POP / 10, 
           group = county,
           date_cutoff = date[min(which(cases >= case_cutoff))],
           day = as.numeric(date - date_cutoff),
           samplesize = max(day),
           exclude = county %in% exclude) %>% 
    ungroup() %>% 
    filter(!is.na(date_cutoff),
           samplesize > min_n,
           !exclude) # remove regions with less than 20 cases total or fewer than 5 days.
  if(nrow(data_by_county) > min_n){
    county_data <- data_by_county %>% 
      group_by(county) %>% 
      summarize(date_cutoff = first(date_cutoff),
                POP = first(POP),
                maxday = max(day)) %>% 
      mutate(start_day = min(c(model_window, predict_window)),
             end_day =  max(c(model_window, predict_window, maxday)))    
    
    all_models <- data_by_county %>% 
      mutate(log10_ar = log10(active)) %>% 
      filter(day <= model_window[2], day >= model_window[1]) %>%  # model using first 2 weeks of data
      group_by(county) %>% 
      nest() %>% 
      mutate(model = map(data, ~lm(log10_ar~day, data = .)))
    
    all_fit <- all_models %>% 
      mutate(fit = map(model, augment, se_fit = TRUE),
             fit = map(fit, select, -c("log10_ar","day"))) %>% 
      select(-model) %>% 
      unnest(cols = c("data","fit")) %>% 
      mutate(fit = 10^.fitted,
             lcl = 10^(.fitted - .se.fit * qt(0.975, df = 10)),
             ucl = 10^(.fitted + .se.fit * qt(0.975, df = 10)))
    
    all_predicted <- cross_df(list(county = unique(pull(data_by_county,county)), 
                                   day = predict_window[1]:predict_window[2])) %>%
      group_by(county) %>%
      nest() %>%
      left_join(select(all_models, county, model), by="county") %>%
      mutate(predicted = map2(model, data, ~augment(.x, newdata = .y, se_fit = TRUE)),
             sigma = map_dbl(model, ~summary(.x)$sigma)) %>%
      select(-c(model,data)) %>%
      unnest(cols = predicted) %>%
      ungroup() %>% 
      left_join(county_data, by = "county") %>% 
      filter(day > pmin(maxday+1, max(model_window))) %>%
      mutate(
        date = date_cutoff + day,
        county = county, # use factor to modify plot order
        fit = 10^.fitted,
        pred_var = sigma^2 + .se.fit^2,
        lpl = 10^(.fitted - sqrt(pred_var)*qt(0.975, df = 10)),
        upl = 10^(.fitted + sqrt(pred_var)*qt(0.975, df = 10)))
    
    doubling_times <- all_models %>% 
      mutate(estimates = map(model, tidy)) %>% 
      unnest(cols = estimates) %>%  # produces 2 rows per country, (intercept) and day100
      filter(term == "day") %>% 
      select(county, estimate, std.error) %>% 
      mutate(var_b = std.error^2,
             t = log10(2) / estimate,
             var_t = var_b * log10(2)^2 / estimate^4,
             lcl_t = t - sqrt(var_t)*qt(0.975, 12),
             ucl_t = t + sqrt(var_t)*qt(0.975, 12),
             label = sprintf("%.2f (%.2f, %.2f)", t, lcl_t, ucl_t))
    
    facet_labels <- doubling_times %>% 
      mutate(label = paste0(county," doubling time (95% CL): ", label)) %>% 
      pull(label)
    names(facet_labels) <- pull(doubling_times, county)
    .plot <- ggplot(data = filter(data_by_county, day >= 0),
                    mapping = aes(x = day)) + 
      geom_point(mapping = aes(y = active, color = county)) + 
      facet_wrap(~county, dir="v", labeller = labeller(county = facet_labels), ncol=2) + 
      scale_y_log10() + 
      theme(legend.position = "none",
            legend.title = element_blank()) + 
      geom_line(data = all_fit,
                mapping = aes(y = fit, color = county),
                size = 1.25) +
      geom_ribbon(data = all_fit,
                  mapping = aes(ymin = lcl, ymax = ucl),
                  alpha = 0.2) +
      geom_line(data = all_predicted,
                mapping = aes(y = fit, color = county),
                linetype = 2) +
      geom_ribbon(data = all_predicted,
                  mapping = aes(ymin = lpl, ymax = upl),
                  alpha = 0.2)  +
      # geom_rect(data = country_data,
      #           mapping = aes(x = start_day, xmin = start_day, xmax = end_day, ymin = icu_beds, ymax = icu_beds * 20),
      #           fill = "red", alpha = 0.2) +
      labs(y = "Active/recovered cases", 
           title = paste0("Active/recovered cases by days since ", case_cutoff, "th case"),
           x = paste0("Days since ", case_cutoff, "th case"),
           subtitle = "Solid line: exponential model; Dashed line: forecast cases with 95% prediction intervals.")   
      # geom_text(data = slice(country_data, 1),
      #           mapping = aes(y = icu_beds),
      #           x = 0, #ymd("2020-03-01"),
      #           label = "# ICU beds / 100K",
      #           size = 2.5, hjust = "left", vjust = "bottom") +
      # geom_text(data = slice(country_data, 1),
      #           mapping = aes(y = 20*icu_beds),
      #           x = 0, #ymd("2020-03-01"),
      #           label = "# 20 times ICU beds / 100K",
      #           size = 2.5, hjust = "left", vjust = "top")
    
  } else {
    .plot = ggplot() # empty ggplot object
    all_models <- all_fit <- doubling_times <- NULL
  }
  
  list(.plot = .plot, data = data_by_county, models = all_models, 
       facet_labels = facet_labels,
       fits = all_fit, predictions = all_predicted, doubling_times = doubling_times)
}