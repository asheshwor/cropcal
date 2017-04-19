#Shiny app to visualise cropping calendar using open data
# github: https://github.com/asheshwor/cropcal
require(shiny)
require(shinydashboard)
require(dplyr)
require(ggplot2)
# require(viridis)
#read data
crop.file <- "data/All_data_with_climate.csv"
crop.data <- read.csv(crop.file,
                      colClasses = c(rep("character", 96)))
#isolate columns
crop.data <- crop.data %>%
  select(3:20)
base::names(crop.data) <- c("Location", "Level", "Nation", "State", "Country",
                            "Crop", "Qualifier", "CropName", "Start",
                            "StartDate",
                            "End", "EndDate", "Median", "range",
                            "HarvestStart", "HarvestStartDate", "HarvestEnd",
                            "HarvestEndDate")
#plot settings
labels <- c(month.abb, "")
breaks <- cumsum(c(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31))
## ui.R ##
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Cropping Calendar", tabName = "dashboard", icon = icon("calendar")),
    menuItem("Table", icon = icon("table"), tabName = "table"),
    menuItem("About", icon = icon("info-circle"), tabName = "about")
  )
)

body <- dashboardBody(
  tabItems(
    tabItem(tabName = "dashboard",
            #h2("Filter data"),
            selectInput("nation",
                        label = "Select location",
                        choices=c((setNames(crop.data$Nation,
                                             paste(crop.data$Location,
                                                   crop.data$Nation))
                                  )),
                        selected=""),
            # h3("Select sub location"),
            conditionalPanel(condition = "output.submenu",
                              uiOutput("subLocation")),
            p("Cropping calendar"),
            plotOutput("crop.graph", height="auto")
            # p("Table"),
            # dataTableOutput("crop.table")
            # p("Cropping calendar will appear here. Eventually.")
    ),
    tabItem(tabName = "table",
            p("Table"),
            dataTableOutput("crop.table")),
    tabItem(tabName = "about",
            includeHTML("about.html")
            
    )
  )
)

shinyApp(
  ui = dashboardPage(skin="red",
    dashboardHeader(title = "Cropping Calendar"),
    dashboardSidebar(sidebar),
    body
  ),
  server = function(input, output, session) {
    #code
    get.crop <- function(x) {
      xdf <- crop.data %>%
        filter(Nation == input$nation)
      return(xdf)
    }
    get.crop.final <- function(x) {
      #add condition
      x <- sublocation()
      if(x>1) {
        xdf <- crop.data %>%
          filter((Nation == input$nation) & (Location == input$sub.location))
      }
      if(x==1) {
        xdf <- get.crop()
      }
      return(xdf)
    }
    get.calendar <- reactive({
      crop.subset <- get.crop.final() %>%
        select(CropName, Start, End, HarvestStart, HarvestEnd) %>%
        mutate(a = as.numeric(Start), b = as.numeric(End), c = as.numeric(End),
               d = as.numeric(HarvestStart), e = as.numeric(HarvestStart),
               f = as.numeric(HarvestEnd))
      #plant with new year
      crop.subset.plant <- crop.subset %>%
        mutate(ab = b-a, cd=d-c, ef=f-e, group = row.names(crop.subset),
               stage="plant")
      crop.split.1 <- crop.subset.plant %>% filter(ab < 0) %>%
        mutate(a = 1)
      crop.split.2 <- crop.subset.plant %>% filter(ab < 0) %>%
        mutate(b = 365)
      crop.table.plant <- crop.subset.plant %>% filter(ab > 0)
      crop.table.plant <- rbind(crop.table.plant, crop.split.1, crop.split.2)
      #maturity with new year
      crop.subset.maturity <- crop.subset %>%
        mutate(ab = b-a, cd=d-c, ef=f-e, group = row.names(crop.subset),
               stage="maturity")
      crop.split.1 <- crop.subset.maturity %>% filter(cd < 0) %>%
        mutate(c = 1)
      crop.split.2 <- crop.subset.maturity %>% filter(cd < 0) %>%
        mutate(d = 365)
      crop.table.maturity <- crop.subset.maturity %>% filter(cd > 0)
      crop.table.maturity <- rbind(crop.table.maturity, crop.split.1, crop.split.2)
      #harvest with new year
      crop.subset.harvest <- crop.subset %>%
        mutate(ab = b-a, cd=d-c, ef=f-e, group = row.names(crop.subset),
               stage="harvest")
      crop.split.1 <- crop.subset.harvest %>% filter(ef < 0) %>%
        mutate(e = 1)
      crop.split.2 <- crop.subset.harvest %>% filter(ef < 0) %>%
        mutate(f = 365)
      crop.table.harvest <- crop.subset.harvest %>% filter(ef > 0)
      crop.table.harvest <- rbind(crop.table.harvest, crop.split.1, crop.split.2)
      #plot
      ggplot() +
        geom_linerange(data=crop.table.maturity, aes(x=CropName, ymin=c, ymax=d,
                                                     color=stage, group=group), size=5, alpha=0.6) +
        geom_linerange(data=crop.table.plant, aes(x=CropName, ymin=a, ymax=b,
                                                  color=stage, group=group), size=7, alpha=0.6) +
        geom_linerange(data=crop.table.harvest, aes(x=CropName, ymin=e, ymax=f,
                                                    color=stage, group=group), size=7, alpha=0.8) +
        ylim(c(0, 365)) +
        coord_flip() +
        ylab("") + xlab("") +
        scale_colour_manual(name="",
                            values = c("aquamarine4", "darkolivegreen3", "cornflowerblue"),
                            labels=c("Harvest", "Growth", "Planting")) +
        theme_minimal() +
        theme(axis.text.x = element_text(hjust = -.5)) +
        coord_flip() + theme(legend.position="bottom") +
        scale_y_continuous("", breaks = breaks, labels = labels, limits = c(0, 365))
    }
    )
    sublocation <- reactive({ #reactive
      xdf <- get.crop()
      mymenu <- length(unique(xdf$Location))
      return(mymenu)
    })
    output$subLocation <- renderUI({
      data <- get.crop()
      mymenu <- unique(data$Location)
      selectInput('sub.location',
                  'Select Sub-location',
                  mymenu)
    })
    output$submenu <- reactive({ #reactive
      x <- sublocation()
      if(x>1) TRUE else FALSE
    })
    #dynamic plot height
    graph.height <- reactive({50 + 40*nrow(get.crop.final())})
    outputOptions(output, "submenu", suspendWhenHidden = FALSE)
    output$crop.graph <- renderPlot(get.calendar(),
                                    height = graph.height)
    # output$crop.graph <- renderPlot(get.calendar(), height = function() {
    #   session$clientData$output_crop.graph_width})
    output$crop.table <- renderDataTable(get.crop.final()[ , c(8,9,11,15,17)])
  }
)