library(shiny)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "My Title"),
  
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
          h1("About Page")
        ),
        fluidRow(
          "Body Text"
        )
      ), #End about tab
      
      tabItem(tabName = "explore",
        column(1,
               radioButtons("raw_data_input", "Select data:",
                            c("All Data Points" = "select_all",
                              "Benign Only" = "select_benign",
                              "Malignant Only" = "select_malignant"))
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
              selectizeInput("scatter_x", "X-axis", choices = colnames(wdbc)[3:32]),
              selectizeInput("scatter_y", "Y-axis", choices = colnames(wdbc)[3:32]),
              checkboxInput("color_diag_scatter", h4("Color-code diagnosis"))
            ),
            column(10, 
              plotlyOutput("scatterplot", width = "100%", height = "600px"),
              br(),
              h4("Click on any point in the plot - its information is displayed below:"),
              box(width = NULL, status = "primary",
                  div(style = 'overflow-x: scroll', tableOutput("clickevent"))
              ),
              br(),
              h4(strong("Note:"), " Download button for the plot is the camera icon at the top of the plot")
            )
          ) #End scatterplot tab
        )
      ), #End summaries tab
      
      tabItem(tabName = "pca",
        column(2,
          selectizeInput("pca_x", "X-axis Principle Component", selected = 1, choices = seq(1,30)),
          selectizeInput("pca_y", "Y-axis Principle Component", selected = 2, choices = seq(1,30)),
          checkboxInput("color_diag_pca", h4("Color-code diagnosis"))
        ),
        column(10,
          conditionalPanel(condition = "input.pca_x == input.pca_y", "X and Y axis values cannot be equal"),
          conditionalPanel(condition = "input.pca_x != input.pca_y", plotlyOutput("biplot", width = "80%", height = "800px"))
        )
      ), #End pca tab
      
      tabItem(tabName = "model",
        tabsetPanel(
          tabPanel("K-Nearest Neighbors",
            column(2,
              numericInput("knn_seed", "Set seed:", value = 10, min = 0, max = 1000, step = 1),
              sliderInput("knn_test", "Set proportion of data set aside for testing: ", min = 0.01, max = 0.5, value = 0.3),
              numericInput("knn_folds", "Set Training Cross-Validation folds: ", value = 5, min = 3, max = 10, step = 1),
              numericInput("knn_repeats", "Set Training CV repeats: ", value = 3, min = 1, max = 5, step = 1),
              sliderInput("knn_slider", "Optimize kNN model for this range of neighbors: ", min = 1, max = 50, value = c(3, 10)),
              checkboxInput("knn_custom_features", "Customize which features to use (if unchecked, the model uses all features)")
            ),
            column(2,
              actionButton("knn_train", "Train kNN Model"),
              conditionalPanel(condition = "input.knn_custom_features",
                checkboxGroupInput("knn_features", "Select features: ",
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
                                                "compactness_worst", "concavity_worst", "concavepoints_worst", "symmetry_worst", "fractal_worst"))
              )
            ),
            column(3,
              conditionalPanel(condition = "input.knn_train",
                h4("Model Performance on Test Data Set"),
                verbatimTextOutput("knn_results"),
                checkboxInput("knn_predict", "Use this model for prediction?")
              )
            ),
            column(2,
              conditionalPanel(condition = "input.knn_predict",
                h4("Predict Using Trained kNN Model"),
                actionButton("knn_predict_action", "Make Prediction"),
                h5("Select values for features:"),
                conditionalPanel(condition = "input.knn_features.includes('radius_mean')",
                  sliderInput("radius_mean_knn", "Radius (Mean)", min = 0, max = 30, value = 15)),
                conditionalPanel(condition = "input.knn_features.includes('texture_mean')",
                  sliderInput("texture_mean_knn", "Texture (Mean)", min = 0, max = 40, value = 20)),
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
                  sliderInput("radius_se_knn", "Radius (Standard Error)", min = 0, max = 3, value = 1.5)),
                conditionalPanel(condition = "input.knn_features.includes('texture_se')",
                  sliderInput("texture_se_knn", "Texture (Standard Error)", min = 0, max = 5, value = 2.5)),
                conditionalPanel(condition = "input.knn_features.includes('perimeter_se')",
                  sliderInput("perimeter_se_knn", "Perimeter (Standard Error)", min = 0, max = 30, value = 15)),
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
                  sliderInput("radius_worst_knn", "Radius (Worst)", min = 0, max = 40, value = 20)),
                conditionalPanel(condition = "input.knn_features.includes('texture_worst')",
                  sliderInput("texture_worst_knn", "Texture (Worst)", min = 0, max = 50, value = 25)),
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
            ),
            column(2,
              conditionalPanel(condition = "input.knn_predict_action", h3(textOutput("knn_pred")))
            )
          ), #End knn tab

          tabPanel("Random Forest"
          ) #End rf tab
        )
      ) #End modeling tab
        
    ) #End tabItems
  ) #End dashboardBody
)
