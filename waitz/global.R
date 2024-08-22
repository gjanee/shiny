library(markdown)
library(shiny)
library(shinyWidgets)
library(tidyverse)

options(dplyr.summarise.inform=FALSE)

# LOCATIONS

locations <- read_csv(
  "data/locations.csv",
  col_types=cols(
    id="i",
    parent_id="i",
    name="c",
    name_indented="c",
    capacity="i",
    earliest_count="D",
    is_active="l"
  )
)

# The locations as read in are in depth-first hierarchical order.  We
# represent location names as an ordered factor both here and further
# below to ensure that that order is preserved.

locations <- locations %>%
  mutate(name=ordered(name, levels=locations$name))

# QUARTERS

quarters <- read_csv(
  "data/quarters.csv",
  col_types=cols(
    name="c",
    start="D",
    end="D",
    start_prev_sunday="D",
    thanksgiving_week_num="i"
  )
)

# Quarters as read in are in calendar order, which again, we want to
# preserve.

quarters <- quarters %>%
  mutate(name=ordered(name, levels=quarters$name))

# DATA

weekdays <- c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")

data <- read_csv(
    "data/data.csv",
    col_types=cols(
      location="c",
      timestamp="T",
      year="i",
      quarter="c",
      quarter_week_num="i",
      weekday="c",
      hour="i",
      count="i",
      percentage="d"
    )
  ) %>%
  filter(percentage < 1.5) # remove crazy large numbers

data <- data %>% mutate(
  location=ordered(location, levels=locations$name),
  quarter=ordered(quarter, levels=quarters$name),
  weekday=ordered(weekday, levels=weekdays)
)

# TIME PERIOD MENU

indentation <- "&nbsp;&nbsp;&nbsp;&nbsp;"

time_period_menu <- c()
time_period_menu_indented <- c()
relevant_quarters <- quarters %>%
  filter(between(name, min(data$quarter), max(data$quarter)))
year <- 0
for (i in rownames(relevant_quarters)) {
  q <- relevant_quarters[i,]
  if (year(q$start) != year) {
    year <- year(q$start)
    time_period_menu <- c(time_period_menu, as.character(year))
    time_period_menu_indented <- (
      c(time_period_menu_indented, as.character(year))
    )
  }
  time_period_menu <- c(time_period_menu, as.character(q$name))
  time_period_menu_indented <- c(
    time_period_menu_indented,
    paste(indentation, as.character(q$name), sep="")
  )
}
