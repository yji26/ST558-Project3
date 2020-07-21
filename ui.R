library(shiny)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "My Title"),
  
  dashboardSidebar(sidebarMenu(
    menuItem("About", tabName = "about", icon = icon("archive")),
    menuItem("Data Exploration", tabName = "explore", icon = icon("search"))
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
        tabsetPanel(
          tabPanel("Raw Data",
            box(width = NULL, status = "primary",
                div(style = 'height:600px; overflow-x: scroll', tableOutput("raw_table"))
            ),
            downloadButton("downloadRaw", "Download")
          ), #End raw data tab
          
          tabPanel("Summary for Numerical Columns",
            box(width = NULL, status = "primary",
                div(style = 'height:250px; overflow-x: scroll', tableOutput("summary_table"))
            ),
            downloadButton("downloadSummary", "Download")
          ), #End summary tab
          
          tabPanel("Boxplot for Numerical Columns",
            fluidRow(
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
              column(10, plotlyOutput("boxplot", width = "60%", height = "800px"))
            )
          ) #End boxplot tab

        )
      ) #End explore tab
    ) #End tabItems
  ) #End dashboardBody
)
