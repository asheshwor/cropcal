#Shiny app to visualize cropping calendar using open data
# see details on the following github
# github: https://github.com/asheshwor/cropcal
# new url: https://app.shrestha.au/cropcal
# CHANGELOG
# 20240128 code changed to update obsolete options
# 20240128 code reworked

# Issues
# Third level of data Level "C" is ignored

require(shiny)
require(shinydashboard)
library(bslib)
require(dplyr)
require(ggplot2)
library(stringr)
library(tidyverse)
library(scales)
library(viridisLite)
library(countrycode)

#READ RAW DATA
crop.file <- "d:/github/cropcal/data/All_data_with_climate.csv"
# crop.file <- "data/All_data_with_climate.csv"
crop.data <- read.csv(crop.file,
                      colClasses = c(rep("character", 96)))
#ISOLATE COLUMNS
crop.data <- crop.data %>%
  dplyr::select(3:20)
base::names(crop.data) <- c("Location", "Level", "Nation", "State", "Country",
                            "Crop", "Qualifier", "CropName", "PlantingStart",
                            "StartDate",
                            "PlantingEnd", "EndDate", "Median", "range",
                            "HarvestStart", "HarvestStartDate", "HarvestEnd",
                            "HarvestEndDate")
# FIRST LEVEL MENU
locations <- crop.data %>%
  dplyr::select(Location, Level, Nation) %>%
  dplyr::filter(Level == "N") %>%
  #fix for the USA
  add_row(Location = "United States of America",
          Level = "N",
          Nation = "5") %>%
  distinct() %>%
  arrange(Location)
crop.data <- crop.data %>%
  dplyr::filter(Level != "C")
# FILTER TEST FOR DEBUG
  # crop.data.sub <- crop.data %>%
  #   filter(Location == "Australia",
  #          Level == "N")
  # str(crop.data.sub)
  # # # END DEBUG
  
  # crop.data.sub <- crop.data.sub %>%
  #   mutate(StartDate = as.Date(StartDate, format = "%m/%d"),
  #          EndDate = as.Date(EndDate, format = "%m/%d"),
  #          HarvestStartDate = as.Date(HarvestStartDate, format = "%m/%d"),
  #          HarvestEndDate = as.Date(HarvestEndDate, format = "%m/%d")) %>%
  #   select(CropName, PlantingStart, PlantingEnd, HarvestStart, HarvestEnd) %>%
  #   mutate(MaturityStart = PlantingEnd, MaturityEnd = HarvestStart)
  # 
# crop.data.start<- crop.data.sub %>% 
#   pivot_longer(cols = ends_with("Start"),
#                names_to = "StageStart",
#                values_to = "StartDate") %>%
#   select(CropName, StageStart, StartDate) %>% 
#   rename(Stage = StageStart) %>% 
#   mutate(Stage = substr(Stage, 1, nchar(Stage) - 5))
# crop.data.end<- crop.data.sub %>% 
#   pivot_longer(cols = ends_with("End"),
#                names_to = "StageEnd",
#                values_to = "EndDate") %>%
#   select(CropName, StageEnd, EndDate) %>% 
#   rename(Stage = StageEnd) %>% 
#   mutate(Stage = substr(Stage, 1, nchar(Stage) - 3))
# crop.data.final <- inner_join(crop.data.start, crop.data.end)

  # pivot_longer(cols = ends_with("End"), names_to = "StageEnd", values_to = "EndDate") %>% 
  # pivot_longer(cols = ends_with("Date"), names_to = "DateCat", values_to = "Date") %>% 
  # pivot_longer(cols = starts_with("Stage"), names_to = "StageCat", values_to = "Stage") %>% 
  # # distinct() %>% 
  # mutate(Stage = substr(Stage, 1, 1)) %>% 
  # select(-StageCat) %>% 
  # distinct() %>% 
  # # group_by(Stage) %>% 
  # pivot_wider(names_from = DateCat, values_from = Date) %>% 
  # ungroup()
  # 
  # 
  # crop.data.sub <- crop.data.sub %>%
  #   select(CropName, PlantingStart, PlantingEnd, HarvestStart, HarvestEnd) %>%
  #   mutate(MaturityStart = PlantingEnd, MaturityEnd = HarvestStart) %>%
  #   pivot_longer(cols = c(PlantingStart, HarvestStart, MaturityStart, PlantingEnd, HarvestEnd, MaturityEnd),
  #                names_to = "Stage", values_to = "DateValue") %>%
  #   mutate(Group = case_when(
  #     str_detect(Stage, "Start") > 0 ~ "Start",
  #     str_detect(Stage, "End") > 0 ~ "End"),
  #     Stage = case_when(
  #       Stage == "PlantingStart" ~ "Planting",
  #       Stage == "MaturityStart" ~ "Growth",
  #       Stage == "HarvestStart" ~ "Harvest",
  #       Stage == "PlantingEnd" ~ "Planting",
  #       Stage == "MaturityEnd" ~ "Growth",
  #       Stage == "HarvestEnd" ~ "Harvest",
  #     )) %>%
  #   mutate(DateValue = as.Date(as.numeric(DateValue), origin = "2024-01-01"),
  #          # Stage = recode(Stage, "Planting" = "Planting", "Harvest" = "Harvest", "Maturity" = "Growth"),
  #          Stage = factor(Stage, levels = c("Planting", "Growth", "Harvest"),
  #                            labels = c("Planting", "Growth", "Harvest"))) %>%
  #   pivot_wider(names_from = Group, values_from = DateValue)
  # 
  # 
# DATELINE SPLIT
#   SPLIT IF A RANGE CROSSES INTO NEW YEAR
# crop.data.sub <- crop.data.sub %>% 
#   mutate(Difference = ifelse((End - Start) > 0, TRUE, FALSE))

# getDates <- function(xstart, xend) {
#   if((xend - xstart) > 0) {
#     ydf = tibble(
#       Starts = xstart,
#       Ends = xend
#     )
#   }
#   else {
#     ydf = tibble(
#       Starts = c(as.Date("2024-01-01"), xstart),
#       Ends = c(xend, as.Date("2024-12-31"))
#     )
#   }
#   return(ydf)
# }
getStart <- function(xstart, xend) {
  ydf = c()
  if((xend - xstart) > 0) {
    ydf = c(xstart)
  }
  else {
    ydf = c(as.Date("2024-01-01"), xstart)
  }
  return(as.Date(ydf))
}
getEnd <- function(xstart, xend) {
  ydf = c()
  if((xend - xstart) > 0) {
    ydf = c(xend)
  }
  else {
    ydf = c(xend, as.Date("2024-12-31"))
  }
  return(as.Date(ydf))
}
# getDates2 <- function(xstart, xend) {
#   mapply(x)
# }
# lapply(list(xstart = crop.data.sub$Start, xend = crop.data.sub$End), getDates)

# mapply(getStart, crop.data.sub$Start, crop.data.sub$End)
# 
#   crop.data.sub <- crop.data.sub %>%
#     mutate(Starts = mapply(getStart, crop.data.sub$Start, crop.data.sub$End),
#            Ends = mapply(getEnd, crop.data.sub$Start, crop.data.sub$End)) %>%
#     dplyr::select(-Start, -End) %>%
#     unnest_longer(c(Starts, Ends)) %>%
#     mutate(Starts = as.Date(Starts),
#            Ends =  as.Date(Ends))

# GRAPH

# 
# crop.data.sub %>%
#   mutate(across(c(`Start`, `End`), getDates))
# 
# crop.data.sub %>%
#   mutate_at(.vars = c(Start, End),
#             .funs = list(A = getDates))
# 
# crop.data.sub %>% mutate(new = getDates(Start, End))
# mapply(getDates, crop.data.sub$Start, crop.data.sub$End)
# getDates(crop.data.sub$Start[3], crop.data.sub$End[3])
# crop.data.sub <- crop.data.sub %>% 
#   group_by(Start, End) %>% 
#   mutate(NewDates = mapply(getDates, crop.data.sub$Start, crop.data.sub$End))

# GGPLOT2 CODE
# crop.data.sub %>% ggplot(aes(y = CropName)) +
#   geom_linerange(aes(xmin = Starts, xmax = Ends, color = Stage),
#                  linewidth = 8) +
#   scale_colour_manual(name="",
#                       values = rev(viridis(4))[2:4],
#                       guide = guide_legend(reverse = FALSE)) +
#   scale_x_date(date_breaks = "1 month", 
#                labels = date_format("%b"),
#                limits = as.Date(c('2024-01-01','2024-12-31')),
#                expand = expansion(mult = c(0, 0))) +
#   theme_minimal() +
#   theme(text = element_text(size=24),
#         axis.text.x = element_text(hjust = -.5),
#         axis.title.x = element_blank(),
#         axis.title.y = element_blank(),
#         legend.position="bottom")
  
#plot settings
# labels <- c(month.abb, "")
# breaks <- cumsum(c(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31))


## ui.R ##
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Cropping Calendar", tabName = "dashboard", icon = icon("leaf")),
    menuItem("Table", icon = icon("table"), tabName = "table"),
    menuItem("About", icon = icon("info-circle"), tabName = "about")
  )
)

body <- dashboardBody(
  tabItems(
    tabItem(tabName = "dashboard",
            #h2("Filter data"),
            selectInput("nation",
                        label = "Select country",
                        # choices=c(setNames(crop.data$Nation,
                        #                      crop.data$Location)),
                        choices=c(setNames(locations$Nation,
                                           locations$Location)),
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
    # FUNCTION TO GET CROP FOR SELECTED LOCATION
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
    
    getStart <- function(xstart, xend) {
      ydf = c()
      if((xend - xstart) > 0) {
        ydf = c(xstart)
      }
      else {
        ydf = c(as.Date("2024-01-01"), xstart)
      }
      return(ydf)
    }
    getEnd <- function(xstart, xend) {
      ydf = c()
      if((xend - xstart) > 0) {
        ydf = c(xend)
      }
      else {
        ydf = c(xend, as.Date("2024-12-31"))
      }
      return(ydf)
    }
    
    get.crop.z <- function(x) {
      crop.subset <- x %>% 
        mutate(StartDate = as.Date(StartDate, format = "%m/%d"),
               EndDate = as.Date(EndDate, format = "%m/%d"),
               HarvestStartDate = as.Date(HarvestStartDate, format = "%m/%d"),
               HarvestEndDate = as.Date(HarvestEndDate, format = "%m/%d")) %>% 
        dplyr::select(CropName, PlantingStart, PlantingEnd, HarvestStart, HarvestEnd) %>%
        mutate(MaturityStart = PlantingEnd, MaturityEnd = HarvestStart) %>%
        dplyr::select(CropName, PlantingStart, PlantingEnd, HarvestStart, HarvestEnd) %>%
        mutate(MaturityStart = PlantingEnd, MaturityEnd = HarvestStart) %>%
        pivot_longer(cols = c(PlantingStart, HarvestStart, MaturityStart, PlantingEnd, HarvestEnd, MaturityEnd),
                     names_to = "Stage", values_to = "DateValue") %>%
        mutate(Group = case_when(
          str_detect(Stage, "Start") > 0 ~ "Start",
          str_detect(Stage, "End") > 0 ~ "End"),
          Stage = case_when(
            Stage == "PlantingStart" ~ "Planting",
            Stage == "MaturityStart" ~ "Growth",
            Stage == "HarvestStart" ~ "Harvest",
            Stage == "PlantingEnd" ~ "Planting",
            Stage == "MaturityEnd" ~ "Growth",
            Stage == "HarvestEnd" ~ "Harvest",
          )) %>%
        mutate(DateValue = as.Date(as.numeric(DateValue), origin = "2024-01-01"),
               Stage = factor(Stage, levels = c("Planting", "Growth", "Harvest"),
                              labels = c("Planting", "Growth", "Harvest"))) %>%
        pivot_wider(names_from = Group, values_from = DateValue)
      startValues <- crop.subset$Start
      endValues <- crop.subset$End
      crop.subset2 <- crop.subset %>% 
        mutate(Starts = mapply(getStart, startValues, endValues),
               Ends = mapply(getEnd, startValues, endValues)) %>%
      # select(-c(Start, End)) %>%
      unnest_longer(c(`Starts`, `Ends`)) %>% 
        mutate(Starts = as.Date(`Starts`),
               Ends =  as.Date(`Ends`))
      return(crop.subset2)
    }
    get.calendar <- reactive({
      # crop.subset <- get.crop.final() %>%
      #   dplyr::select(CropName, PlantingStart, PlantingEnd, HarvestStart, HarvestEnd) %>%
      #   mutate(a = as.numeric(Start), b = as.numeric(End), c = as.numeric(End),
      #          d = as.numeric(HarvestStart), e = as.numeric(HarvestStart),
      #          f = as.numeric(HarvestEnd))
      # #the following code could be more tidyversy :-|
      # #plant with new year
      # crop.subset.plant <- crop.subset %>%
      #   mutate(ab = b-a, cd=d-c, ef=f-e, group = row.names(crop.subset),
      #          stage="plant")
      # crop.split.1 <- crop.subset.plant %>% filter(ab < 0) %>%
      #   mutate(a = 1)
      # crop.split.2 <- crop.subset.plant %>% filter(ab < 0) %>%
      #   mutate(b = 365)
      # crop.table.plant <- crop.subset.plant %>% filter(ab > 0)
      # crop.table.plant <- rbind(crop.table.plant, crop.split.1, crop.split.2)
      # #maturity with new year
      # crop.subset.maturity <- crop.subset %>%
      #   mutate(ab = b-a, cd=d-c, ef=f-e, group = row.names(crop.subset),
      #          stage="maturity")
      # crop.split.1 <- crop.subset.maturity %>% filter(cd < 0) %>%
      #   mutate(c = 1)
      # crop.split.2 <- crop.subset.maturity %>% filter(cd < 0) %>%
      #   mutate(d = 365)
      # crop.table.maturity <- crop.subset.maturity %>% filter(cd > 0)
      # crop.table.maturity <- rbind(crop.table.maturity, crop.split.1, crop.split.2)
      # #harvest with new year
      # crop.subset.harvest <- crop.subset %>%
      #   mutate(ab = b-a, cd=d-c, ef=f-e, group = row.names(crop.subset),
      #          stage="harvest")
      # crop.split.1 <- crop.subset.harvest %>% filter(ef < 0) %>%
      #   mutate(e = 1)
      # crop.split.2 <- crop.subset.harvest %>% filter(ef < 0) %>%
      #   mutate(f = 365)
      # crop.table.harvest <- crop.subset.harvest %>% filter(ef > 0)
      # crop.table.harvest <- rbind(crop.table.harvest, crop.split.1, crop.split.2)
      # PLOT CODE
      # GGPLOT2 CODE
      get.crop.z(get.crop.final()) %>% ggplot(aes(y = CropName)) +
        geom_linerange(aes(xmin = Starts, xmax = Ends, color = Stage),
                       linewidth = 8) +
        scale_colour_manual(name="",
                            values = rev(viridis(4))[2:4],
                            guide = guide_legend(reverse = FALSE)) +
        scale_x_date(date_breaks = "1 month", 
                     labels = date_format("%b"),
                     limits = as.Date(c('2024-01-01','2024-12-31')),
                     expand = expansion(mult = c(0, 0))) +
        theme_minimal() +
        theme(text = element_text(size=24),
              axis.text.x = element_text(hjust = -.5),
              axis.title.x = element_blank(),
              axis.title.y = element_blank(),
              legend.position="bottom")
    }
    )
    get.crop.table <- function(x) {
      ydf <- x %>%
        mutate(PlantingStart = format(as.Date(StartDate, format = "%m/%d"), "%b %d"),
               PlantingEnd = format(as.Date(EndDate, format = "%m/%d"), "%b %d"),
               HarvestStart = format(as.Date(HarvestStartDate, format = "%m/%d"), "%b %d"),
               HarvestEnd = format(as.Date(HarvestEndDate, format = "%m/%d"), "%b %d")) %>% 
        dplyr::select(Location, State, Qualifier, CropName,
                      PlantingStart, PlantingEnd, HarvestStart, HarvestEnd)
      return(ydf)
    }
    sublocation <- reactive({ #reactive
      xdf <- get.crop()
      mymenu <- length(unique(xdf$Location))
      return(mymenu)
    })
    output$subLocation <- renderUI({
      data <- get.crop()
      mymenu <- unique(data$Location)
      selectInput('sub.location',
                  'Select location',
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
    # output$crop.table <- renderDataTable(get.crop.final()) #[ , c(8,9,11,15,17)]
    # output$crop.table <- renderDataTable(get.crop.z(get.crop.final()))
    output$crop.table <- renderDataTable(get.crop.table(get.crop.final()))
  }
)