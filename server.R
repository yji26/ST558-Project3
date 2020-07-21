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
  #wdbc <- wdbc %>% arrange(diagnosis)
  
  #Render raw data table
  output$raw_table <- renderTable(wdbc)
  output$downloadRaw <- downloadHandler(
    filename = "WDBCRawData.csv",
    content = function(file) {
      write.csv(wdbc, file, row.names = FALSE)
    }
  )
  
  #Render summary table
  output$summary_table <- renderTable(apply(wdbc[, 3:32], 2, summary), rownames = TRUE)
  output$downloadSummary <- downloadHandler(
    filename = "WDBCSummaryData.csv",
    content = function(file) {
      write.csv(apply(wdbc[, 3:32], 2, summary), file, row.names = TRUE)
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
  
})
