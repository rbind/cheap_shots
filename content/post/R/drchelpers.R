# function to get the predicted values out
augment_drc <- function(x, newdata = NULL, interval = "none"){
  if (is.null(newdata)){
    result <- predict_drc(x, interval = interval)
    orig_data <- x$origData
  } else {
    result <- predict_drc(x, newdata = newdata, interval = interval)
    orig_data <- newdata
  }
  if(interval == "none"){
    result <- bind_cols(orig_data, tibble(Prediction = result)) # result is a vector
  } else {
    result <- bind_cols(orig_data, as_tibble(result)) # result is a matrix
  }
  return(result)
}

predict_drc <- function (object, newdata, se.fit = FALSE, interval = c("none", 
                                                        "confidence", "prediction"), level = 0.95, na.action = na.pass, 
          od = FALSE, vcov. = vcov, ...) 
{
  interval <- match.arg(interval)
  respType <- object[["type"]]
  dataList <- object[["dataList"]]
  doseDim <- ncol(dataList[["dose"]])
  if (is.null(doseDim)) {
    doseDim <- 1
  }
  if (missing(newdata)) {
    doseVec <- dataList[["dose"]]
    if (identical(respType, "event")) {
      groupLevels <- as.character(dataList[["plotid"]])
    }
    else {
      groupLevels <- as.character(dataList[["curveid"]])
    }
  }
  else {
    dName <- dataList[["names"]][["dName"]]
    if (any(names(newdata) %in% dName)) {
      doseVec <- newdata[, dName]
    }
    else {
      doseVec <- newdata[, 1]
    }
    cName <- dataList[["names"]][["cNames"]]
    if (any(names(newdata) %in% cName)) {
      groupLevels <- as.character(newdata[, cName])
    }
    else {
      groupLevels <- rep(1, nrow(newdata))
    }
  }
  noNewData <- length(groupLevels)
  powerExp <- (object$curve)[[2]]
  if (!is.null(powerExp)) {
    doseVec <- powerExp^doseVec
  }
  parmMat <- object[["parmMat"]]
  pm <- t(parmMat[, groupLevels, drop = FALSE])
  sumObj <- summary(object, od = od)
  vcovMat <- vcov.(object)
  indexMat <- object[["indexMat"]]
  retMat <- matrix(0, noNewData, 4)
  colnames(retMat) <- c("Prediction", "SE", "Lower", "Upper")
  objFct <- object[["fct"]]
  retMat[, 1] <- objFct$fct(doseVec, pm)
  deriv1 <- objFct$deriv1
  if (is.null(deriv1)) {
    return(retMat[, 1])
  }
  if (!identical(interval, "none")) {
    if (identical(respType, "continuous")) {
      tquan <- qt(1 - (1 - level)/2, df.residual(object))
    }
    else {
      tquan <- qnorm(1 - (1 - level)/2)
    }
  }
  if (se.fit || (!identical(interval, "none"))) {
    if (identical(interval, "prediction")) {
      sumObjRV <- sumObj$resVar
    }
    else {
      sumObjRV <- 0
    }
    piMat <- indexMat[, groupLevels, drop = FALSE]
    for (rowIndex in 1:noNewData) {
      parmInd <- piMat[, rowIndex]
      varCov <- vcovMat[parmInd, parmInd]
      dfEval <- deriv1(doseVec[rowIndex], pm[rowIndex, 
                                             , drop = FALSE])
      varVal <- dfEval %*% varCov %*% dfEval
      retMat[rowIndex, 2] <- sqrt(varVal)
      if (!se.fit) {
        retMat[rowIndex, 3:4] <- retMat[rowIndex, 1] + 
          (tquan * sqrt(varVal + sumObjRV)) * c(-1, 
                                                1)
      }
    }
  }
  keepInd <- 1
  if (se.fit) {
    keepInd <- c(keepInd, 2)
  }
  if (!identical(interval, "none")) {
    keepInd <- c(keepInd, 3, 4)
  }
  return(retMat[, keepInd])
}
