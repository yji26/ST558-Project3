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

shinyServer(function(input, output, session) {
  
  wdbc <- read_csv("wdbc.data", col_names = FALSE)
  colnames(wdbc) <- c("id", "diagnosis", 
                      "radius_mean", "texture_mean", "perimeter_mean", "area_mean", "smoothness_mean", "compactness_mean", "concavity_mean", "concavepoints_mean", "symmetry_mean", "fractal_mean",
                      "radius_se", "texture_se", "perimeter_se", "area_se", "smoothness_se", "compactness_se", "concavity_se", "concavepoints_se", "symmetry_se", "fractal_se",
                      "radius_worst", "texture_worst", "perimeter_worst", "area_worst", "smoothness_worst", "compactness_worst", "concavity_worst", "concavepoints_worst", "symmetry_worst", "fractal_worst"
  )
  
  wdbc$diagnosis <- as.factor(wdbc$diagnosis)
  
  output$raw_table <- renderTable(wdbc)
  output$downloadRaw <- downloadHandler(
    filename = "WDBCRawData.csv",
    content = function(file) {
      write.csv(wdbc, file, row.names = FALSE)
    }
  )
  
  output$summary_table <- renderTable(apply(wdbc[, 3:32], 2, summary), rownames = TRUE)
  output$downloadSummary <- downloadHandler(
    filename = "WDBCSummaryData.csv",
    content = function(file) {
      write.csv(apply(wdbc[, 3:32], 2, summary), file, row.names = TRUE)
    }
  )

  output$boxplot <- renderPlotly({
    g <- ggplot(data = wdbc, aes(x = diagnosis, y = eval(as.symbol(input$box_input)))) + 
      geom_boxplot() + labs(title = paste0("Boxplot for ", input$box_input, " measurements \nbetween Benign and Malignant diagnoses")) + 
      labs(y = input$box_input)
    ggplotly(g)
  })
})
