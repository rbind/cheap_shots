# function to get the predicted values out
augment_drc <- function(x, newdata = NULL, interval = "none"){
  if (is.null(newdata)){
    result <- predict(x, interval = interval)
    orig_data <- x$origData
  } else {
    result <- predict(x, newdata = newdata, interval = interval)
    orig_data <- newdata
  }
  if(interval == "none"){
    result <- bind_cols(orig_data, tibble(Prediction = result)) # result is a vector
  } else {
    result <- bind_cols(orig_data, as_tibble(result)) # result is a matrix
  }
  return(result)
}

