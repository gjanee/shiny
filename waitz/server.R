function(input, output, session) {

  observeEvent(
    input$time_periods,
    {
      if (length(input$time_periods) == length(time_period_menu)) {
        # The "Select All Years" button was pushed, and now every menu
        # item is selected.  Update the menu so that only years are
        # selected.
        updatePickerInput(
          session=session,
          inputId="time_periods",
          selected=time_period_menu[str_detect(time_period_menu, "^\\d{4}$")]
        )
      }
    }
  )

  output$plot <- renderPlot({

    if (length(input$time_periods) == length(time_period_menu)) {
      # The "Select All Years" button was pushed, and now every menu
      # item is selected.  Let the above code do its magic so we get
      # called again with a proper selection.
      return(NA)
    }

    # Gather input selections
    sel_locations <- input$locations
    sel_years <- as.integer(
      input$time_periods[str_detect(input$time_periods, "^\\d{4}$")]
    )
    sel_quarters <- (
      input$time_periods[!str_detect(input$time_periods, "^\\d{4}$")]
    )

    # Validate inputs
    validate(
      need(length(sel_locations) > 0, "Select at least one location"),
      need(
        length(sel_years)+length(sel_quarters) > 0,
        "Select at least one time period"
      ),
      need(
        (
          length(sel_locations) <= 1 |
          length(sel_years)+length(sel_quarters) <= 1
        ),
        "Can't select multiple locations and multiple time periods"
      ),
      need(
        length(sel_years) == 0 | length(sel_quarters) == 0,
        "Select years or quarters, not both"
      )
    )

    # Arrange axes.  There's a bunch of meta-programming below because
    # the plotting code is written to be (mostly) independent of the
    # columns being plotted.  In the following, `scol` is the column
    # (location or time period) with the singular selection; and
    # `sval` is that selection (a 1-element vector).  `mcol` is the
    # column with the multiple selection, and `mval` is the
    # corresponding selection (a multi-element vector).
    if (length(sel_locations) > 1) {
      mcol <- "location"
      mval <- sel_locations
      if (length(sel_years) > 0) {
        scol <- "year"
        sval <- sel_years
      } else {
        scol <- "quarter"
        sval <- sel_quarters
      }
      legend_title <- "Location"
      plot_title <- paste("Occupancy during", sval)
    } else {
      if (length(sel_years) > 0) {
        mcol <- "year"
        mval <- sel_years
      } else {
        mcol <- "quarter"
        mval <- sel_quarters
      }
      scol <- "location"
      sval <- sel_locations
      legend_title <- "Year"
      plot_title <- paste("Occupancy of", sval)
    }

    # `xcol` is the column that will eventually become the X axis.
    xcol <- input$plot_type

    if (xcol == "quarter_week_num") {
      x_axis_label <- "Week in quarter"
    } else if (xcol == "weekday") {
      x_axis_label <- "Day in week"
    } else if (xcol == "hour") {
      x_axis_label <- "Hour in day"
    }

    # Gather data
    plot_data <- data %>%
      filter(get(scol) %in% sval) %>%
      filter(get(mcol) %in% mval)

    if (input$restrict_hours) {
      plot_data <- plot_data %>% filter(between(hour, 8, 16))
    }

    plot_data <- plot_data %>%
      group_by_at(c(mcol, xcol)) %>%
      summarize(plot_data=mean(percentage)*100)

    # Column fixups.  Grouped columns must be factors.  But plotting
    # continuous lines requires that the X axis not be a factor.
    if (xcol == "weekday") {
      plot_data <- plot_data %>% mutate(weekday=as.integer(weekday))
    }
    if (mcol == "year") {
      plot_data <- plot_data %>% mutate(year=as.factor(year))
    }

    # Perform final grouping and plot
    plot <- plot_data %>%
      group_by_at(mcol) %>%
      ggplot(aes(x=get(xcol), y=plot_data, color=get(mcol))) +
        geom_line(linewidth=1) +
        scale_y_continuous(limits=c(0, 100)) +
        labs(title=plot_title, color=legend_title) +
        xlab(x_axis_label) +
        ylab("Mean occupancy percentage") +
        theme(plot.title=element_text(size=20))

    # Final tweaks and return value
    if (xcol == "quarter_week_num") {
      plot + scale_x_continuous(breaks=1:11)
    } else if (xcol == "weekday") {
      plot + scale_x_continuous(breaks=1:7, label=weekdays)
    } else if (xcol == "hour") {
      plot + scale_x_continuous(breaks=0:23)
    }

  })

}
