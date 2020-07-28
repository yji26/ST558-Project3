library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(caret)
library(e1071)
library(randomForest)
library(plotly)
library(ggfortify)

dashboardPage(
  dashboardHeader(title = "Data Exploration and Modeling Dashboard", titleWidth = 400),
  
  dashboardSidebar(sidebarMenu(
    menuItem("About", tabName = "about", icon = icon("archive")),
    menuItem("Data Exploration", tabName = "explore", icon = icon("search")),
    menuItem("Data Summaries", tabName = "summaries", icon = icon("chart-bar", lib = "font-awesome")),
    menuItem("Principal Component Analysis", tabName = "pca", icon = icon("eye")),
    menuItem("Predictive Modeling", tabName = "model", icon = icon("chart-line", lib = "font-awesome"))
  )),
  
  dashboardBody(
    tabItems(
      
      tabItem(tabName = "about",
        fluidRow(
          column(3,
            box(width = NULL, status = "primary",
              h2("Dashboard Overview"),
              "This dashboard provides data exploration, data summary and modeling tools used to analyze a breast cancer diagnosis data set from the University of Wisconsin. The original data set may be downloaded from ",
              tags$a(href = "https://archive.ics.uci.edu/ml/datasets/Breast+Cancer+Wisconsin+%28Diagnostic%29", "this link"),
              " and contains one column for ID, one for diagnosis (the response or target variable), and 30 columns describing the mean, standard error and worst-value measurements for ten numerical features."
            )
          ),
          column(9,
            box(width = NULL, status = "primary",
              withMathJax(),
              h2("Tab Summaries"),
              h3("Data Exploration Tab"),
              "This tab outputs the raw data set. User can filter the data set by the response variable value (B for Benign and M for Malignant diagnosis) or choose the unfiltered data set containing all data rows. In addition, there is a Download buttom below that allows the user to download the currently displayed data as a csv file.",
              br(),
              h3("Data Summaries Tab"),
              "These tabs provides some common summaries for the 30 numerical features of the data set.",
              h4("Numerical Summary Tables"),
              "Provides the Minimum, 1st Quartile, Median, Mean, 3rd Quartile, and Maximum values of each feature. Like the raw data set, these summaries may be subset by the response variable and downloaded.",
              br(),
              h4("Boxplots"),
              "Compares the boxplots for each feature, subset by the response variable. The user may mouse hover over the plots to display additional boxplot information, as well as download the plot as an image and the underlying data set as a csv.",
              br(),
              h4("Scatterplots"),
              "Plots two user-selected features as a scatterplot. The user may color-code the response variable to better visualize the clustering of benign and malignant diagnoses in relation to the selected features. The user may also left-click on any data point on the scatterplot to display full feature information for that data point below the plot. User may download the plot as an image file and the underlying data set as a csv.",
              br(),
              br(),
              tags$b("Note: "), "All plots are shown using the ", tags$em("plotly"), " package, which enables common features such as zoom, region select and autoscale. The full list of features are shown when hovering over the upper-right corner of each plot.",
              h3("Principal Component Analysis Tab"),
              helpText("PCA is used to project the features data onto an orthogonal basis while maximizing the variance of each successive dimension. The first principal component, labeled \\(PC1\\), accounts for the most variance and the last principal component, labeled \\(PC30\\), accounts for the least variance. Since they form an orthogonal basis, it means that \\(PC1 \\bot PC2 \\bot PC3 \\bot ... \\bot PC30\\), and any pair of principal components can be selected as the axes to a biplot. The PCA biplot displays the influence each feature has on a principal component. Users may choose which principal components to plot, and each principal component label displays a percentage figure which indicates the percent of overall variance that component captures. Like with the other plots, user may color-code by the response, download the plot as an image file and the underlying data set as a csv."),
              h3("Predictive Modeling Tab"),
              "This tab enables the user to train k-Nearest Neighbors and Random Forest models to predict diagnosis from the 30 features. The user may select any combination of features to put in the model, as well as hyperparameter settings for each model type. Clicking the Train Model button will kick off the training, and after a short duration the UI should return the predicted outcomes of the model in the test data set against their actual outcomes, along with accuracy metrics. If the checkbox for ",
              tags$b("Use this model for a custom prediction?"),
              "is selected, the UI will bring up sliders for the picked model features and allow the user to make their own prediction of a diagnosis on custom input data."
            )
          )
        )
      ), #End about tab
      
      tabItem(tabName = "explore",
        column(1,
          radioButtons("raw_data_input", "Select data:",
                       c("All Data Points" = "select_all",
                         "Benign Only" = "select_benign",
                         "Malignant Only" = "select_malignant")
          )
        ),
        column(11,
          box(width = NULL, status = "primary",
              div(style = 'height:600px; overflow-x: scroll', tableOutput("raw_table"))
          ),
          downloadButton("downloadRaw", "Download")
        )
      ), #End explore tab
              
      tabItem(tabName = "summaries",
        tabsetPanel(
          tabPanel("Summary Table for Numerical Columns",
            column(1,
              radioButtons("summary_input", "Select data:",
                           c("All Data Points" = "select_all",
                             "Benign Only" = "select_benign",
                             "Malignant Only" = "select_malignant"))
            ),
            column(11,
              box(width = NULL, status = "primary",
                  div(style = 'height:250px; overflow-x: scroll', tableOutput("summary_table"))
              ),
              downloadButton("downloadSummary", "Download")
            )
          ), #End summary tab
          
          tabPanel("Boxplot for Numerical Columns",
            column(2,
              radioButtons("box_input", "Column:",
                           c("Radius (Mean)" = "radius_mean",
                             "Texture (Mean)" = "texture_mean",
                             "Perimeter (Mean)" = "perimeter_mean",
                             "Area (Mean)" = "area_mean",
                             "Smoothness (Mean)" = "smoothness_mean",
                             "Compactness (Mean)" = "compactness_mean",
                             "Concavity (Mean)" = "concavity_mean",
                             "Concave Points (Mean)" = "concavepoints_mean",
                             "Symmetry (Mean)" = "symmetry_mean",
                             "Fractal Dimension (Mean)" = "fractal_mean",
                             "Radius (Standard Error)" = "radius_se",
                             "Texture (Standard Error)" = "texture_se",
                             "Perimeter (Standard Error)" = "perimeter_se",
                             "Area (Standard Error)" = "area_se",
                             "Smoothness (Standard Error)" = "smoothness_se",
                             "Compactness (Standard Error)" = "compactness_se",
                             "Concavity (Standard Error)" = "concavity_se",
                             "Concave Points (Standard Error)" = "concavepoints_se",
                             "Symmetry (Standard Error)" = "symmetry_se",
                             "Fractal Dimension (Standard Error)" = "fractal_se",
                             "Radius (Worst)" = "radius_worst",
                             "Texture (Worst)" = "texture_worst",
                             "Perimeter (Worst)" = "perimeter_worst",
                             "Area (Worst)" = "area_worst",
                             "Smoothness (Worst)" = "smoothness_worst",
                             "Compactness (Worst)" = "compactness_worst",
                             "Concavity (Worst)" = "concavity_worst",
                             "Concave Points (Worst)" = "concavepoints_worst",
                             "Symmetry (Worst)" = "symmetry_worst",
                             "Fractal Dimension (Worst)" = "fractal_worst")
              )
            ),
            column(10,
              plotlyOutput("boxplot", width = "60%", height = "700px"),
              br(),
              downloadButton("downloadBoxplotData", "Download Data"),
              br(),
              h4(strong("Note:"), " Download button for the plot is the camera icon at the top of the plot")
            )
          ), #End boxplot tab

          tabPanel("Scatterplot for Numerical Columns",
            column(2,
              selectizeInput("scatter_x", "X-axis", choices = c("radius_mean", "texture_mean", "perimeter_mean", "area_mean", "smoothness_mean", 
                                                                "compactness_mean", "concavity_mean", "concavepoints_mean", "symmetry_mean", "fractal_mean",
                                                                "radius_se", "texture_se", "perimeter_se", "area_se", "smoothness_se", 
                                                                "compactness_se", "concavity_se", "concavepoints_se", "symmetry_se", "fractal_se",
                                                                "radius_worst", "texture_worst", "perimeter_worst", "area_worst", "smoothness_worst", 
                                                                "compactness_worst", "concavity_worst", "concavepoints_worst", "symmetry_worst", "fractal_worst"
                                                               )
              ),
              selectizeInput("scatter_y", "Y-axis", choices = c("radius_mean", "texture_mean", "perimeter_mean", "area_mean", "smoothness_mean", 
                                                                "compactness_mean", "concavity_mean", "concavepoints_mean", "symmetry_mean", "fractal_mean",
                                                                "radius_se", "texture_se", "perimeter_se", "area_se", "smoothness_se", 
                                                                "compactness_se", "concavity_se", "concavepoints_se", "symmetry_se", "fractal_se",
                                                                "radius_worst", "texture_worst", "perimeter_worst", "area_worst", "smoothness_worst", 
                                                                "compactness_worst", "concavity_worst", "concavepoints_worst", "symmetry_worst", "fractal_worst"
                                                               )
              ),
              checkboxInput("color_diag_scatter", h4("Color-code diagnosis"))
            ),
            column(10, 
              plotlyOutput("scatterplot", width = "100%", height = "600px"),
              br(),
              downloadButton("downloadScatterplotData", "Download Data"),
              h4(strong("Note:"), " Download button for the plot is the camera icon at the top of the plot"),
              br(),
              h4("Click on any point in the scatterplot - its full information is displayed below:"),
              box(width = NULL, status = "primary",
                  div(style = 'overflow-x: scroll', tableOutput("clickevent"))
              )
            )
          ) #End scatterplot tab
        )
      ), #End summaries tab
      
      tabItem(tabName = "pca",
        column(2,
          selectizeInput("pca_x", "X-axis Principal Component", selected = 1, choices = seq(1,30)),
          selectizeInput("pca_y", "Y-axis Principal Component", selected = 2, choices = seq(1,30)),
          checkboxInput("color_diag_pca", h4("Color-code diagnosis"))
        ),
        column(10,
          conditionalPanel(condition = "input.pca_x == input.pca_y", "X and Y axis values cannot be equal"),
          conditionalPanel(condition = "input.pca_x != input.pca_y", 
            fluidRow(
              plotlyOutput("biplot", width = "80%", height = "800px"),
              br(),
              downloadButton("downloadBiplotData", "Download Data")
            )
          )
        )
      ), #End pca tab
      
      tabItem(tabName = "model",
        tabsetPanel(
          tabPanel("K-Nearest Neighbors",
                   
            #Model Parameters and Settings
            column(4,
              fluidRow(
                h3("Model Parameters"),
                actionButton("knn_train", "Train kNN Model", icon = icon("star", lib = "font-awesome")), 
                align = "center"
              ),
              fluidRow(
                column(6,
                  h4("Feature Selection"),
                  checkboxGroupInput("knn_features", label = NULL,
                                     choices = c("Radius (Mean)" = "radius_mean",
                                                 "Texture (Mean)" = "texture_mean",
                                                 "Perimeter (Mean)" = "perimeter_mean",
                                                 "Area (Mean)" = "area_mean",
                                                 "Smoothness (Mean)" = "smoothness_mean",
                                                 "Compactness (Mean)" = "compactness_mean",
                                                 "Concavity (Mean)" = "concavity_mean",
                                                 "Concave Points (Mean)" = "concavepoints_mean",
                                                 "Symmetry (Mean)" = "symmetry_mean",
                                                 "Fractal Dimension (Mean)" = "fractal_mean",
                                                 "Radius (Standard Error)" = "radius_se",
                                                 "Texture (Standard Error)" = "texture_se",
                                                 "Perimeter (Standard Error)" = "perimeter_se",
                                                 "Area (Standard Error)" = "area_se",
                                                 "Smoothness (Standard Error)" = "smoothness_se",
                                                 "Compactness (Standard Error)" = "compactness_se",
                                                 "Concavity (Standard Error)" = "concavity_se",
                                                 "Concave Points (Standard Error)" = "concavepoints_se",
                                                 "Symmetry (Standard Error)" = "symmetry_se",
                                                 "Fractal Dimension (Standard Error)" = "fractal_se",
                                                 "Radius (Worst)" = "radius_worst",
                                                 "Texture (Worst)" = "texture_worst",
                                                 "Perimeter (Worst)" = "perimeter_worst",
                                                 "Area (Worst)" = "area_worst",
                                                 "Smoothness (Worst)" = "smoothness_worst",
                                                 "Compactness (Worst)" = "compactness_worst",
                                                 "Concavity (Worst)" = "concavity_worst",
                                                 "Concave Points (Worst)" = "concavepoints_worst",
                                                 "Symmetry (Worst)" = "symmetry_worst",
                                                 "Fractal Dimension (Worst)" = "fractal_worst"),
                                     selected = c("radius_mean", "texture_mean", "perimeter_mean", "area_mean", "smoothness_mean", 
                                                  "compactness_mean", "concavity_mean", "concavepoints_mean", "symmetry_mean", "fractal_mean", 
                                                  "radius_se", "texture_se", "perimeter_se", "area_se", "smoothness_se", 
                                                  "compactness_se", "concavity_se", "concavepoints_se", "symmetry_se", "fractal_se", 
                                                  "radius_worst", "texture_worst", "perimeter_worst", "area_worst", "smoothness_worst", 
                                                  "compactness_worst", "concavity_worst", "concavepoints_worst", "symmetry_worst", "fractal_worst"),
                                     inline = FALSE)
                ),
                column(6,
                  h4("Hyperparameter Settings"),
                  numericInput("knn_seed", "Set seed:", value = 10, min = 0, max = 1000, step = 1),
                  sliderInput("knn_test", "Proportion of data set aside for testing: ", min = 0.01, max = 0.5, value = 0.3),
                  numericInput("knn_folds", "Set Training Cross-Validation folds: ", value = 5, min = 3, max = 10, step = 1),
                  numericInput("knn_repeats", "Set Training Cross-Validation repeats: ", value = 3, min = 1, max = 5, step = 1),
                  sliderInput("knn_slider", "Test model for this range of neighbors: ", min = 1, max = 50, value = c(3, 10))
                )
              ) #End fluidRow
            ),
      
            #Model Test Set Performance
            column(3,
              conditionalPanel(condition = "input.knn_train",
                h3("Model Performance on Test Data Set"),
                verbatimTextOutput("knn_results"),
                checkboxInput("knn_predict", "Use this model for a custom prediction?")
              )
            ),
            
            #Custom Prediction from User Input
            column(3,
              conditionalPanel(condition = "input.knn_predict",
                h3("Custom Prediction Using Trained kNN Model"),
                actionButton("knn_predict_action", "Make Prediction", icon = icon("exclamation", lib = "font-awesome")),
                h4("Select values for features:"),
                box(width = NULL, status = "primary",
                    div(style = 'height:600px; overflow-x: scroll',
                    conditionalPanel(condition = "input.knn_features.includes('radius_mean')",
                      sliderInput("radius_mean_knn", "Radius (Mean)", min = 0, max = 30, value = 15, step = 0.1)),
                    conditionalPanel(condition = "input.knn_features.includes('texture_mean')",
                      sliderInput("texture_mean_knn", "Texture (Mean)", min = 0, max = 40, value = 20, step = 0.1)),
                    conditionalPanel(condition = "input.knn_features.includes('perimeter_mean')",
                      sliderInput("perimeter_mean_knn", "Perimeter (Mean)", min = 0, max = 200, value = 100)),
                    conditionalPanel(condition = "input.knn_features.includes('area_mean')",
                      sliderInput("area_mean_knn", "Area (Mean)", min = 0, max = 3000, value = 1500)),
                    conditionalPanel(condition = "input.knn_features.includes('smoothness_mean')",
                      sliderInput("smoothness_mean_knn", "Smoothness (Mean)", min = 0, max = 0.2, value = 0.1)),
                    conditionalPanel(condition = "input.knn_features.includes('compactness_mean')",
                      sliderInput("compactness_mean_knn", "Compactness (Mean)", min = 0, max = 0.4, value = 0.2)),
                    conditionalPanel(condition = "input.knn_features.includes('concavity_mean')",
                      sliderInput("concavity_mean_knn", "Concavity (Mean)", min = 0, max = 0.5, value = 0.25)),
                    conditionalPanel(condition = "input.knn_features.includes('concavepoints_mean')",
                      sliderInput("concavepoints_mean_knn", "Concave Points (Mean)", min = 0, max = 0.2, value = 0.1)),
                    conditionalPanel(condition = "input.knn_features.includes('symmetry_mean')",
                      sliderInput("symmetry_mean_knn", "Symmetry (Mean)", min = 0, max = 0.4, value = 0.2)),
                    conditionalPanel(condition = "input.knn_features.includes('fractal_mean')",
                      sliderInput("fractal_mean_knn", "Fractal Dimension (Mean)", min = 0, max = 0.2, value = 0.1)),
                    conditionalPanel(condition = "input.knn_features.includes('radius_se')",
                      sliderInput("radius_se_knn", "Radius (Standard Error)", min = 0, max = 3, value = 1.5, step = 0.1)),
                    conditionalPanel(condition = "input.knn_features.includes('texture_se')",
                      sliderInput("texture_se_knn", "Texture (Standard Error)", min = 0, max = 5, value = 2.5, step = 0.1)),
                    conditionalPanel(condition = "input.knn_features.includes('perimeter_se')",
                      sliderInput("perimeter_se_knn", "Perimeter (Standard Error)", min = 0, max = 30, value = 15, step = 0.1)),
                    conditionalPanel(condition = "input.knn_features.includes('area_se')",
                      sliderInput("area_se_knn", "Area (Standard Error)", min = 0, max = 600, value = 300)),
                    conditionalPanel(condition = "input.knn_features.includes('smoothness_se')",
                      sliderInput("smoothness_se_knn", "Smoothness (Standard Error)", min = 0, max = 0.05, value = 0.025)),
                    conditionalPanel(condition = "input.knn_features.includes('compactness_se')",
                      sliderInput("compactness_se_knn", "Compactness (Standard Error)", min = 0, max = 0.2, value = 0.1)),
                    conditionalPanel(condition = "input.knn_features.includes('concavity_se')",
                      sliderInput("concavity_se_knn", "Concavity (Standard Error)", min = 0, max = 0.5, value = 0.25)),
                    conditionalPanel(condition = "input.knn_features.includes('concavepoints_se')",
                      sliderInput("concavepoints_se_knn", "Concave Points (Standard Error)", min = 0, max = 0.1, value = 0.05)),
                    conditionalPanel(condition = "input.knn_features.includes('symmetry_se')",
                      sliderInput("symmetry_se_knn", "Symmetry (Standard Error)", min = 0, max = 0.1, value = 0.05)),
                    conditionalPanel(condition = "input.knn_features.includes('fractal_se')",
                      sliderInput("fractal_se_knn", "Fractal Dimension (Standard Error)", min = 0, max = 0.05, value = 0.025)),
                    conditionalPanel(condition = "input.knn_features.includes('radius_worst')",
                      sliderInput("radius_worst_knn", "Radius (Worst)", min = 0, max = 40, value = 20, step = 0.1)),
                    conditionalPanel(condition = "input.knn_features.includes('texture_worst')",
                      sliderInput("texture_worst_knn", "Texture (Worst)", min = 0, max = 50, value = 25, step = 0.1)),
                    conditionalPanel(condition = "input.knn_features.includes('perimeter_worst')",
                      sliderInput("perimeter_worst_knn", "Perimeter (Worst)", min = 0, max = 300, value = 150)),
                    conditionalPanel(condition = "input.knn_features.includes('area_worst')",
                      sliderInput("area_worst_knn", "Area (Worst)", min = 0, max = 5000, value = 2500)),
                    conditionalPanel(condition = "input.knn_features.includes('smoothness_worst')",
                      sliderInput("smoothness_worst_knn", "Smoothness (Worst)", min = 0, max = 0.25, value = 0.125)),
                    conditionalPanel(condition = "input.knn_features.includes('compactness_worst')",
                      sliderInput("compactness_worst_knn", "Compactness (Worst)", min = 0, max = 1.2, value = 0.6)),
                    conditionalPanel(condition = "input.knn_features.includes('concavity_worst')",
                      sliderInput("concavity_worst_knn", "Concavity (Worst)", min = 0, max = 1.5, value = 0.75)),
                    conditionalPanel(condition = "input.knn_features.includes('concavepoints_worst')",
                      sliderInput("concavepoints_worst_knn", "Concave Points (Worst)", min = 0, max = 0.3, value = 0.15)),
                    conditionalPanel(condition = "input.knn_features.includes('symmetry_worst')",
                      sliderInput("symmetry_worst_knn", "Symmetry (Worst)", min = 0, max = 0.7, value = 0.35)),
                    conditionalPanel(condition = "input.knn_features.includes('fractal_worst')",
                      sliderInput("fractal_worst_knn", "Fractal Dimension (Worst)", min = 0, max = 0.25, value = 0.125))
                  )
                )
              )
            ),
            
            #Show Custom Prediction
            column(2,
              conditionalPanel(condition = "input.knn_predict_action", h3(textOutput("knn_pred")))
            )
          ), #End knn tab

          tabPanel("Random Forest",
                   
            #Model Parameters and Settings
            column(4,
              fluidRow(
                h3("Model Parameters"),
                actionButton("rf_train", "Train Random Forest Model", icon = icon("star", lib = "font-awesome")), 
                align = "center"
              ),
              fluidRow(
                column(6,
                  h4("Feature Selection"),
                  checkboxGroupInput("rf_features", label = NULL,
                                     choices = c("Radius (Mean)" = "radius_mean",
                                                 "Texture (Mean)" = "texture_mean",
                                                 "Perimeter (Mean)" = "perimeter_mean",
                                                 "Area (Mean)" = "area_mean",
                                                 "Smoothness (Mean)" = "smoothness_mean",
                                                 "Compactness (Mean)" = "compactness_mean",
                                                 "Concavity (Mean)" = "concavity_mean",
                                                 "Concave Points (Mean)" = "concavepoints_mean",
                                                 "Symmetry (Mean)" = "symmetry_mean",
                                                 "Fractal Dimension (Mean)" = "fractal_mean",
                                                 "Radius (Standard Error)" = "radius_se",
                                                 "Texture (Standard Error)" = "texture_se",
                                                 "Perimeter (Standard Error)" = "perimeter_se",
                                                 "Area (Standard Error)" = "area_se",
                                                 "Smoothness (Standard Error)" = "smoothness_se",
                                                 "Compactness (Standard Error)" = "compactness_se",
                                                 "Concavity (Standard Error)" = "concavity_se",
                                                 "Concave Points (Standard Error)" = "concavepoints_se",
                                                 "Symmetry (Standard Error)" = "symmetry_se",
                                                 "Fractal Dimension (Standard Error)" = "fractal_se",
                                                 "Radius (Worst)" = "radius_worst",
                                                 "Texture (Worst)" = "texture_worst",
                                                 "Perimeter (Worst)" = "perimeter_worst",
                                                 "Area (Worst)" = "area_worst",
                                                 "Smoothness (Worst)" = "smoothness_worst",
                                                 "Compactness (Worst)" = "compactness_worst",
                                                 "Concavity (Worst)" = "concavity_worst",
                                                 "Concave Points (Worst)" = "concavepoints_worst",
                                                 "Symmetry (Worst)" = "symmetry_worst",
                                                 "Fractal Dimension (Worst)" = "fractal_worst"),
                                    selected = c("radius_mean", "texture_mean", "perimeter_mean", "area_mean", "smoothness_mean", 
                                                 "compactness_mean", "concavity_mean", "concavepoints_mean", "symmetry_mean", "fractal_mean", 
                                                 "radius_se", "texture_se", "perimeter_se", "area_se", "smoothness_se", 
                                                 "compactness_se", "concavity_se", "concavepoints_se", "symmetry_se", "fractal_se", 
                                                 "radius_worst", "texture_worst", "perimeter_worst", "area_worst", "smoothness_worst", 
                                                 "compactness_worst", "concavity_worst", "concavepoints_worst", "symmetry_worst", "fractal_worst"),
                                    inline = FALSE)
                ),
                column(6,
                  h4("Hyperparameter Settings"),
                  numericInput("rf_seed", "Set seed:", value = 10, min = 0, max = 1000, step = 1),
                  sliderInput("rf_test", "Proportion of data set aside for testing: ", min = 0.01, max = 0.5, value = 0.3),
                  numericInput("rf_folds", "Set Training Cross-Validation folds: ", value = 5, min = 3, max = 10, step = 1),
                  numericInput("rf_repeats", "Set Training Cross-Validation repeats: ", value = 3, min = 1, max = 5, step = 1),
                  sliderInput("rf_slider", "Number of variables to consider in the model: ", min = 1, max = 30, value = c(1, 10))
                )
              ) #End fluidRow
            ),
             
            #Model Test Set Performance
            column(3,
              conditionalPanel(condition = "input.rf_train",
                h3("Model Performance on Test Data Set"),
                verbatimTextOutput("rf_results"),
                checkboxInput("rf_predict", "Use this model for a custom prediction?")
              )
            ),
             
            #Custom Prediction from User Input
            column(3,
              conditionalPanel(condition = "input.rf_predict",
                h3("Custom Prediction Using Trained Random Forest Model"),
                actionButton("rf_predict_action", "Make Prediction", icon = icon("exclamation", lib = "font-awesome")),
                h4("Select values for features:"),
                box(width = NULL, status = "primary",
                    div(style = 'height:600px; overflow-x: scroll', 
                    conditionalPanel(condition = "input.rf_features.includes('radius_mean')",
                      sliderInput("radius_mean_rf", "Radius (Mean)", min = 0, max = 30, value = 15, step = 0.1)),
                    conditionalPanel(condition = "input.rf_features.includes('texture_mean')",
                      sliderInput("texture_mean_rf", "Texture (Mean)", min = 0, max = 40, value = 20, step = 0.1)),
                    conditionalPanel(condition = "input.rf_features.includes('perimeter_mean')",
                      sliderInput("perimeter_mean_rf", "Perimeter (Mean)", min = 0, max = 200, value = 100)),
                    conditionalPanel(condition = "input.rf_features.includes('area_mean')",
                      sliderInput("area_mean_rf", "Area (Mean)", min = 0, max = 3000, value = 1500)),
                    conditionalPanel(condition = "input.rf_features.includes('smoothness_mean')",
                      sliderInput("smoothness_mean_rf", "Smoothness (Mean)", min = 0, max = 0.2, value = 0.1)),
                    conditionalPanel(condition = "input.rf_features.includes('compactness_mean')",
                      sliderInput("compactness_mean_rf", "Compactness (Mean)", min = 0, max = 0.4, value = 0.2)),
                    conditionalPanel(condition = "input.rf_features.includes('concavity_mean')",
                      sliderInput("concavity_mean_rf", "Concavity (Mean)", min = 0, max = 0.5, value = 0.25)),
                    conditionalPanel(condition = "input.rf_features.includes('concavepoints_mean')",
                      sliderInput("concavepoints_mean_rf", "Concave Points (Mean)", min = 0, max = 0.2, value = 0.1)),
                    conditionalPanel(condition = "input.rf_features.includes('symmetry_mean')",
                      sliderInput("symmetry_mean_rf", "Symmetry (Mean)", min = 0, max = 0.4, value = 0.2)),
                    conditionalPanel(condition = "input.rf_features.includes('fractal_mean')",
                      sliderInput("fractal_mean_rf", "Fractal Dimension (Mean)", min = 0, max = 0.2, value = 0.1)),
                    conditionalPanel(condition = "input.rf_features.includes('radius_se')",
                      sliderInput("radius_se_rf", "Radius (Standard Error)", min = 0, max = 3, value = 1.5, step = 0.1)),
                    conditionalPanel(condition = "input.rf_features.includes('texture_se')",
                      sliderInput("texture_se_rf", "Texture (Standard Error)", min = 0, max = 5, value = 2.5, step = 0.1)),
                    conditionalPanel(condition = "input.rf_features.includes('perimeter_se')",
                      sliderInput("perimeter_se_rf", "Perimeter (Standard Error)", min = 0, max = 30, value = 15, step = 0.1)),
                    conditionalPanel(condition = "input.rf_features.includes('area_se')",
                      sliderInput("area_se_rf", "Area (Standard Error)", min = 0, max = 600, value = 300)),
                    conditionalPanel(condition = "input.rf_features.includes('smoothness_se')",
                      sliderInput("smoothness_se_rf", "Smoothness (Standard Error)", min = 0, max = 0.05, value = 0.025)),
                    conditionalPanel(condition = "input.rf_features.includes('compactness_se')",
                      sliderInput("compactness_se_rf", "Compactness (Standard Error)", min = 0, max = 0.2, value = 0.1)),
                    conditionalPanel(condition = "input.rf_features.includes('concavity_se')",
                      sliderInput("concavity_se_rf", "Concavity (Standard Error)", min = 0, max = 0.5, value = 0.25)),
                    conditionalPanel(condition = "input.rf_features.includes('concavepoints_se')",
                      sliderInput("concavepoints_se_rf", "Concave Points (Standard Error)", min = 0, max = 0.1, value = 0.05)),
                    conditionalPanel(condition = "input.rf_features.includes('symmetry_se')",
                      sliderInput("symmetry_se_rf", "Symmetry (Standard Error)", min = 0, max = 0.1, value = 0.05)),
                    conditionalPanel(condition = "input.rf_features.includes('fractal_se')",
                      sliderInput("fractal_se_rf", "Fractal Dimension (Standard Error)", min = 0, max = 0.05, value = 0.025)),
                    conditionalPanel(condition = "input.rf_features.includes('radius_worst')",
                      sliderInput("radius_worst_rf", "Radius (Worst)", min = 0, max = 40, value = 20, step = 0.1)),
                    conditionalPanel(condition = "input.rf_features.includes('texture_worst')",
                      sliderInput("texture_worst_rf", "Texture (Worst)", min = 0, max = 50, value = 25, step = 0.1)),
                    conditionalPanel(condition = "input.rf_features.includes('perimeter_worst')",
                      sliderInput("perimeter_worst_rf", "Perimeter (Worst)", min = 0, max = 300, value = 150)),
                    conditionalPanel(condition = "input.rf_features.includes('area_worst')",
                      sliderInput("area_worst_rf", "Area (Worst)", min = 0, max = 5000, value = 2500)),
                    conditionalPanel(condition = "input.rf_features.includes('smoothness_worst')",
                      sliderInput("smoothness_worst_rf", "Smoothness (Worst)", min = 0, max = 0.25, value = 0.125)),
                    conditionalPanel(condition = "input.rf_features.includes('compactness_worst')",
                      sliderInput("compactness_worst_rf", "Compactness (Worst)", min = 0, max = 1.2, value = 0.6)),
                    conditionalPanel(condition = "input.rf_features.includes('concavity_worst')",
                      sliderInput("concavity_worst_rf", "Concavity (Worst)", min = 0, max = 1.5, value = 0.75)),
                    conditionalPanel(condition = "input.rf_features.includes('concavepoints_worst')",
                      sliderInput("concavepoints_worst_rf", "Concave Points (Worst)", min = 0, max = 0.3, value = 0.15)),
                    conditionalPanel(condition = "input.rf_features.includes('symmetry_worst')",
                      sliderInput("symmetry_worst_rf", "Symmetry (Worst)", min = 0, max = 0.7, value = 0.35)),
                    conditionalPanel(condition = "input.rf_features.includes('fractal_worst')",
                      sliderInput("fractal_worst_rf", "Fractal Dimension (Worst)", min = 0, max = 0.25, value = 0.125))
                  )
                )
              )
            ),
             
            #Show Custom Prediction
            column(2,
              conditionalPanel(condition = "input.rf_predict_action", h3(textOutput("rf_pred")))
            )
          ) #End rf tab
          
        )
      ) #End modeling tab
        
    ) #End tabItems
  ) #End dashboardBody
)
