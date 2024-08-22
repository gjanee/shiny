navbarPage(
  title = "UCSB Library Building Occupancy",
  header = tags$head(
    tags$link(rel="stylesheet", type="text/css", href="styles.css")
  ),
  tabPanel(
    title = "About",
    fluidRow(
      column(1),
      column(10, includeMarkdown("text/about.md")),
      column(1)
    )
  ),
  tabPanel(
    title = "Explore the data",
    p(
      paste(
        "Compare multiple locations over one time period,",
        "or one location over multiple time periods."
      )
    ),
    sidebarLayout(
      sidebarPanel(
        pickerInput(
          inputId = "plot_type",
          label = "Plot type (X axis):",
          choices = c("quarter_week_num", "weekday", "hour"),
          selected = "quarter_week_num",
          choicesOpt = list(
            content=c("Weeks in quarter", "Days in week", "Hours in day")
          )
        ),
        pickerInput(
          inputId = "locations",
          label = "Location(s):",
          choices = locations$name,
          selected = filter(locations, is.na(parent_id))$name,
          choicesOpt = list(content=locations$name_indented),
          options = pickerOptions(actionsBox=TRUE),
          multiple = TRUE
        ),
        pickerInput(
          inputId = "time_periods",
          label = "Time period(s):",
          choices = time_period_menu,
          selected = max(data$academic_year),
          choicesOpt = list(content=time_period_menu_indented),
          options = pickerOptions(
            actionsBox=TRUE,
            selectAllText="Select All Years"
          ),
          multiple = TRUE
        ),
        checkboxInput(
          inputId = "restrict_hours",
          label = "Restrict to building hours (8am-8pm)",
          value = FALSE
        )
      ),
      mainPanel(
        plotOutput("plot")
      )
    )
  )
)
