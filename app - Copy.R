require(shiny)
require(shinydashboard)
require(dplyr)
require(ggplot2)
#read data
crop.file <- "//Uofa/users$/users5/a1634565/github/cropcal/data/All_data_with_climate.csv"  
crop.data <- read.csv(crop.file,
                      # skip = 1,
                      colClasses = c(rep("character", 96)))
#isolate necessary columns
crop.data <- crop.data %>%
  select(3:20)
base::names(crop.data) <- c("Location", "Level", "Nation", "State", "Country",
                            "Crop", "Qualifier", "CropName", "Start",
                            "StartDate",
                            "End", "EndDate", "Median", "range",
                            "HarvestStart", "HarvestStartDate", "HarvestEnd",
                            "HarvestEndDate")
## ui.R ##
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("About", icon = icon("th"), tabName = "about",
             badgeLabel = "new", badgeColor = "green")
  )
)

body <- dashboardBody(
  tabItems(
    tabItem(tabName = "dashboard",
            h2("Filter data"),
            selectInput("nation",
                        label = "Select Nation",
                        choices=c(#None = '.',
                                  sort(
                                    setNames(crop.data$Nation,
                                             paste(crop.data$Location,
                                                   crop.data$Nation))
                                  )),
                        selected=""),
            # h3("Select sub location"),
            conditionalPanel(condition = "output.nrows",
                              uiOutput("subLocation")),
            h2("Cropping calendar"),
            plotOutput("crop.graph", height=400),
            h2("Table"),
            dataTableOutput("crop.table")
            # p("Cropping calendar will appear here. Eventually.")
    ),
    
    tabItem(tabName = "about",
            h2("Description"),
            p("test"),
            h2("Data source"),
            p("https://nelson.wisc.edu/sage/data-and-models/crop-calendar-dataset/index.php")
            
    )
  )
)

# Put them together into a dashboardPage
dashboardPage(
  dashboardHeader(title = "Simple tabs"),
  sidebar,
  body
)

shinyApp(
  ui = dashboardPage(
    dashboardHeader(title = "Cropping Calendar"),
    dashboardSidebar(sidebar),
    body
  ),
  server = function(input, output) {
    #code
    get.crop <- function(x) {
      xdf <- crop.data %>%
        filter(Nation == input$nation)
      return(xdf)
    }
    # get.crop.final <- function(x) {
    #   xdf <- crop.data %>%
    #     filter((Nation == input$nation) & (Location == input$sub.location))
    #   return(xdf)
    # }
    get.calendar <- reactive({
      crop.table <- crop.data %>%
        filter((Nation == input$nation) & (Location == input$sub.location)) %>%
        select(CropName, Start, End, HarvestStart, HarvestEnd) %>%
        mutate(Start = as.numeric(Start), End = as.numeric(End),
               HarvestStart = as.numeric(HarvestStart),
               HarvestEnd = as.numeric(HarvestEnd))
      #plot
      ggplot(data=crop.table) +
        geom_linerange(aes(x=CropName, ymin=Start, ymax=End,
                           color="aquamarine4"), size=5, alpha=0.5) +
        geom_linerange(aes(x=CropName, ymin=End, ymax=HarvestStart,
                           color="darkolivegreen3"), size=2, alpha=0.5) +
        geom_linerange(aes(x=CropName, ymin=HarvestStart, ymax=HarvestEnd,
                           color="cornflowerblue"), size=7, alpha=0.5) +
        xlab("") + ylab("") +
        coord_flip() + theme(legend.position="none")
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
    output$nrows <- reactive({ #reactive
      x <- sublocation()
      if(x>1) TRUE else FALSE
    })
    outputOptions(output, "nrows", suspendWhenHidden = FALSE)
    output$crop.graph <- renderPlot(get.calendar())
    output$crop.table <- renderDataTable(get.crop.final()[ , c(8,9,11,15,17)])
  }
)


# # test
# crop.sub <- crop.data %>%
#   filter(crop.data$Nation == "108") #102 #108
# crop.table.plant <- crop.sub %>%
#   select(CropName, Start, End, HarvestStart, HarvestEnd) %>%
#   mutate(a = as.numeric(Start), b = as.numeric(End), c = as.numeric(End),
#          d = as.numeric(HarvestStart), e = as.numeric(HarvestStart),
#          f = as.numeric(HarvestEnd)) %>%
#   mutate(ab = b-a, cd=d-c, ef=f-e, group = row.names(crop.sub))
# #plant with new year
# crop.split.1 <- crop.table.plant %>% filter(ab < 0) %>%
#   mutate(a = 1)
# crop.split.2 <- crop.table.plant %>% filter(ab < 0) %>%
#   mutate(b = 365)
# crop.table.plant <- crop.table.plant %>% filter(ab > 0)
# crop.table.plant <- rbind(crop.table.plant, crop.split.1, crop.split.2)
# #maturity with new year
# crop.table.maturity <- crop.sub %>%
#   select(CropName, Start, End, HarvestStart, HarvestEnd) %>%
#   mutate(a = as.numeric(Start), b = as.numeric(End), c = as.numeric(End),
#          d = as.numeric(HarvestStart), e = as.numeric(HarvestStart),
#          f = as.numeric(HarvestEnd)) %>%
#   mutate(ab = b-a, cd=d-c, ef=f-e, group = row.names(crop.sub))
# #plant with new year
# crop.split.1 <- crop.table.maturity %>% filter(cd < 0) %>%
#   mutate(c = 1)
# crop.split.2 <- crop.table.maturity %>% filter(cd < 0) %>%
#   mutate(d = 365)
# crop.table.maturity <- crop.table.maturity %>% filter(cd > 0)
# crop.table.maturity <- rbind(crop.table.maturity, crop.split.1, crop.split.2)
# #harvest with new year
# crop.table.harvest <- crop.sub %>%
#   select(CropName, Start, End, HarvestStart, HarvestEnd) %>%
#   mutate(a = as.numeric(Start), b = as.numeric(End), c = as.numeric(End),
#          d = as.numeric(HarvestStart), e = as.numeric(HarvestStart),
#          f = as.numeric(HarvestEnd)) %>%
#   mutate(ab = b-a, cd=d-c, ef=f-e, group = row.names(crop.sub))
# #plant with new year
# crop.split.1 <- crop.table.harvest %>% filter(ef < 0) %>%
#   mutate(e = 1)
# crop.split.2 <- crop.table.harvest %>% filter(ef < 0) %>%
#   mutate(f = 365)
# crop.table.harvest <- crop.table.harvest %>% filter(ef > 0)
# crop.table.harvest <- rbind(crop.table.harvest, crop.split.1, crop.split.2)
# #plot
# Labels <- c(month.abb, "")
# Breaks <- cumsum(c(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31))
# ggplot() +
#   geom_linerange(data=crop.table.plant, aes(x=CropName, ymin=a, ymax=b,
#                      color="cornflowerblue", group=group), size=7, alpha=0.6) +
#   geom_linerange(data=crop.table.maturity, aes(x=CropName, ymin=c, ymax=d,
#                      color="darkolivegreen3", group=group), size=5, alpha=0.6) +
#   geom_linerange(data=crop.table.harvest, aes(x=CropName, ymin=e, ymax=f,
#                      color="aquamarine4", group=group), size=2, alpha=0.8) +
#   xlab("") + ylab("") + ylim(c(0,365)) +
#   coord_flip() + theme(legend.position="none") + scale_y_continuous("", breaks = Breaks, labels = Labels, limits = c(0, 365))