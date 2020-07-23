library(shiny)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(knitr)
library(DT)
library(caret)
library(e1071)
library(randomForest)
library(gbm)
library(rgl)
library(tree)
library(plotly)
library(ggfortify)
library(htmlwidgets)

shinyServer(function(input, output, session) {
  #Read in and label the data
  wdbc <- read_csv("wdbc.data", col_names = FALSE)
  colnames(wdbc) <- c("id", "diagnosis", 
                      "radius_mean", "texture_mean", "perimeter_mean", "area_mean", "smoothness_mean", "compactness_mean", "concavity_mean", "concavepoints_mean", "symmetry_mean", "fractal_mean",
                      "radius_se", "texture_se", "perimeter_se", "area_se", "smoothness_se", "compactness_se", "concavity_se", "concavepoints_se", "symmetry_se", "fractal_se",
                      "radius_worst", "texture_worst", "perimeter_worst", "area_worst", "smoothness_worst", "compactness_worst", "concavity_worst", "concavepoints_worst", "symmetry_worst", "fractal_worst"
  )
  wdbc$id <- as.character(wdbc$id)
  wdbc$diagnosis <- as.factor(wdbc$diagnosis)
  
  #Split into train-test
  reactive({
    set.seed(1)
    train <- sample(1:nrow(wdbc), size = nrow(wdbc)*0.8)
    test <- dplyr::setdiff(1:nrow(wdbc), train)
    wdbcTrain <- wdbc[train, ] %>% select(-id)
    wdbcTest <- wdbc[test, ] %>% select(-id)
  })
  
  #Render raw data table
  filteredData <- reactive({
    if (input$raw_data_input == "select_benign") {
      wdbc %>% filter(diagnosis == "B")
    } else if (input$raw_data_input == "select_malignant") {
      wdbc %>% filter(diagnosis == "M")
    } else {
      wdbc
    }
  })
  
  output$raw_table <- renderTable(filteredData())
  output$downloadRaw <- downloadHandler(
    filename = "WDBCData.csv",
    content = function(file) {
      write.csv(filteredData(), file, row.names = FALSE)
    }
  )
  
  #Render summary table
  filteredSummaryData <- reactive({
    if (input$summary_input == "select_benign") {
      wdbc %>% filter(diagnosis == "B")
    } else if (input$summary_input == "select_malignant") {
      wdbc %>% filter(diagnosis == "M")
    } else {
      wdbc
    }
  })
  
  output$summary_table <- renderTable(apply(filteredSummaryData()[, 3:32], 2, summary), rownames = TRUE)
  output$downloadSummary <- downloadHandler(
    filename = "WDBCSummaryData.csv",
    content = function(file) {
      write.csv(apply(filteredSummaryData()[, 3:32], 2, summary), file, row.names = TRUE)
    }
  )

  #Render boxplot
  output$boxplot <- renderPlotly({
    g <- ggplot(data = wdbc, aes(x = diagnosis, y = eval(as.symbol(input$box_input)))) + 
      geom_boxplot() + labs(title = paste0("Boxplot for ", input$box_input, " measurements \nbetween Benign and Malignant diagnoses")) + 
      labs(y = input$box_input)
    g
  })
  
  output$downloadBoxplotData <- downloadHandler(
    filename = "WDBCBoxplotData.csv",
    content = function(file) {
      write.csv(wdbc[, c("diagnosis", input$box_input)], file, row.names = FALSE)
    }
  )
  
  #Render scatterplot
  output$scatterplot <- renderPlotly({
    if (input$color_diag_scatter) {
      g <- ggplot(data = wdbc, aes(x = eval(as.symbol(input$scatter_x)), y = eval(as.symbol(input$scatter_y)), color = diagnosis))
    } else {
      g <- ggplot(data = wdbc, aes(x = eval(as.symbol(input$scatter_x)), y = eval(as.symbol(input$scatter_y))))
    }
    ggplotly(g + geom_point() + 
                 labs(title = paste0("Scatterplot for ", input$scatter_x, " vs. ", input$scatter_y), 
                      x = input$scatter_x, y = input$scatter_y),
             source = "A"
    )
  })
  
  #Render scatterplot info table based on user click
  output$clickevent <- renderTable({
    if (length(event_data("plotly_click")) > 0) {
      event_data <- event_data("plotly_click")
      wdbc %>% filter((eval(as.symbol(input$scatter_x)) == event_data$x) & (eval(as.symbol(input$scatter_y)) == event_data$y))
    } else {
      wdbc[0, ]
    }
  })
  
  #Render PCA biplot
  output$biplot <- renderPlotly({
    PCs <- prcomp(wdbc[, 3:32], center = TRUE, scale = TRUE)
    if (input$color_diag_pca) {
      a <- autoplot(PCs, data = wdbc, x = as.numeric(input$pca_x), y = as.numeric(input$pca_y), 
                    colour = "diagnosis", loadings = TRUE, loadings.colour = 'black', 
                    loadings.label = TRUE, loadings.label.size = 5, loadings.label.colour = 'black')
    } else {
      a <- autoplot(PCs, data = wdbc, x = as.numeric(input$pca_x), y = as.numeric(input$pca_y), 
                    loadings = TRUE, loadings.colour = 'black', 
                    loadings.label = TRUE, loadings.label.size = 5, loadings.label.colour = 'black')
    }
    ggplotly(a + labs(title = "Principle Component Analysis Biplot"))
  })
  
  #Train kNN model
  knn_model_list <- reactive({
    input$knn_train
    
    knn_out <- isolate({
      wdbcKnn <- wdbc[, c("diagnosis", input$knn_features), drop = FALSE]
      
      set.seed(input$knn_seed)
      train <- sample(1:nrow(wdbcKnn), size = nrow(wdbcKnn)*(1-input$knn_test))
      test <- dplyr::setdiff(1:nrow(wdbcKnn), train)
      wdbcKnnTrain <- wdbcKnn[train, ]
      wdbcKnnTest <- wdbcKnn[test, ]
      
      trctrl <- trainControl(method = "repeatedcv", number = input$knn_folds, repeats = input$knn_repeats)
      
      knn_fit <- train(diagnosis ~ ., 
                       data = wdbcKnnTrain, 
                       method = "knn",
                       trControl = trctrl,
                       preProcess = c("center", "scale"),
                       tuneGrid = expand.grid(k = seq(input$knn_slider[[1]], input$knn_slider[[2]])))
      
      out_temp <- capture.output(
        confusionMatrix(
          predict(knn_fit, newdata = wdbcKnnTest), 
          wdbcKnnTest$diagnosis
        ))
      
      return(list(wdbcKnnTrain, wdbcKnnTest, knn_fit, out_temp))
    })
    
    knn_out
  })
  
  #Output kNN model results
  output$knn_results <- renderText({
    out_temp <- knn_model_list()[[4]]
    for (i in 1:length(out_temp)) {
      out_temp[i] <- paste0(out_temp[i], "\n")
    }
    out_temp
  })
  
  #Make prediction for kNN model
  output$knn_pred <- renderText({
    input$knn_predict_action
    
    knn_predict_output <- isolate({
      knn_userinput <- data.frame("radius_mean" = input$radius_mean_knn, 
                                  "texture_mean" = input$texture_mean_knn, 
                                  "perimeter_mean" = input$perimeter_mean_knn, 
                                  "area_mean" = input$area_mean_knn, 
                                  "smoothness_mean" = input$smoothness_mean_knn, 
                                  "compactness_mean" = input$compactness_mean_knn, 
                                  "concavity_mean" = input$concavity_mean_knn, 
                                  "concavepoints_mean" = input$concavepoints_mean_knn, 
                                  "symmetry_mean" = input$symmetry_mean_knn, 
                                  "fractal_mean" = input$fractal_mean_knn, 
                                  "radius_se" = input$radius_se_knn, 
                                  "texture_se" = input$texture_se_knn, 
                                  "perimeter_se" = input$perimeter_se_knn, 
                                  "area_se" = input$area_se_knn, 
                                  "smoothness_se" = input$smoothness_se_knn, 
                                  "compactness_se" = input$compactness_se_knn, 
                                  "concavity_se" = input$concavity_se_knn, 
                                  "concavepoints_se" = input$concavepoints_se_knn, 
                                  "symmetry_se" = input$symmetry_se_knn, 
                                  "fractal_se" = input$fractal_se_knn, 
                                  "radius_worst" = input$radius_worst_knn, 
                                  "texture_worst" = input$texture_worst_knn, 
                                  "perimeter_worst" = input$perimeter_worst_knn, 
                                  "area_worst" = input$area_worst_knn, 
                                  "smoothness_worst" = input$smoothness_worst_knn, 
                                  "compactness_worst" = input$compactness_worst_knn, 
                                  "concavity_worst" = input$concavity_worst_knn, 
                                  "concavepoints_worst" = input$concavepoints_worst_knn, 
                                  "symmetry_worst" = input$symmetry_worst_knn, 
                                  "fractal_worst" = input$fractal_worst_knn)
      
      wdbcKnnPred <- predict(knn_model_list()[[3]], newdata = knn_userinput)
      if (wdbcKnnPred[[1]] == "M") {
        return("The model prediction is: Malignant")
      } else {
        return("The model prediction is: Benign")
      }
    })
    
    knn_predict_output
  })
  

})
