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
          tabPanel("K-Nearest Neighbors"
          ), #End knn tab

          tabPanel("Random Forest"
          ) #End rf tab
        )
      ) #End modeling tab
        
    ) #End tabItems
  ) #End dashboardBody
)
