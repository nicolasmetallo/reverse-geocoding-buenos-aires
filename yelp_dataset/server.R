library(shiny)
library(shinyBS)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)

busdata = allbus

shinyServer(function(input, output, session) {

  # Create the map
  map <- createLeafletMap(session, "map")

  # A reactive expression that returns the set of businesses that are
  # in bounds right now
  busInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(busdata[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(busdata,
      lat >= latRng[1] & lat <= latRng[2] &
        long >= lngRng[1] & long <= lngRng[2])
  })
  
  # Precalculate the breaks we'll need for the two histograms
  pvalueBreaks <- hist(plot = FALSE, allbus$pvalues, breaks = 20)$breaks

  output$histpvals <- renderPlot({
    # If no businesses are in view, don't plot
    if (nrow(busInBounds()) == 0)
      return(NULL)
    
    hist(busInBounds()$pvalues,
      breaks = pvalueBreaks,
      main = "P-values (Visible Businesses)",
      xlab = "p-value",
      xlim = range(allbus$pvalues),
      col = '#00DD00',
      border = 'white')
  })
  
  # session$onFlushed is necessary to work around a bug in the Shiny/Leaflet
  # integration; without it, the addCircle commands arrive in the browser
  # before the map is created.
  session$onFlushed(once=TRUE, function() {
    paintObs <- observe({
      colorBy <- input$color
      sizeBy <- input$size

      colorData <- if (colorBy == "significant") {
        as.numeric(allbus$qvalues < (input$threshold/100))
      } else if(colorBy == "pvalues" | colorBy == "qvalues") {
	-log(allbus[[colorBy]])
      } else {
        allbus[[colorBy]]
      }
      colors <- brewer.pal(10, "RdYlGn")[cut(colorData, breaks=10, labels = FALSE)]
      colors <- colors[match(busdata$business, allbus$business)]

      scaledData <- (allbus[[sizeBy]] / max(allbus[[sizeBy]]))
      sizeData <- if(sizeBy == "constantsize") {
	rep(30,nrow(allbus))
      } else if(sizeBy == "totalsamples") {
	scaledData * 300
      } else if(sizeBy == "totalreviewscore") {
	log((scaledData-.01)/(1-(scaledData-.01))) * 30
      } else {
	-log(scaledData) * 30
      }
      
      # Clear existing circles before drawing
      map$clearShapes()
      # Draw in batches of 1000; makes the app feel a bit more responsive
      chunksize <- 1000
      for (from in seq.int(1, nrow(busdata), chunksize)) {
        to <- min(nrow(busdata), from + chunksize)
        buschunk <- busdata[from:to,]
        # Bug in Shiny causes this to error out when user closes browser
        # before we get here
        try(
          map$addCircle(
            buschunk$lat, buschunk$long,
            sizeData[from:to],
            buschunk$business,
            list(stroke=FALSE, fill=TRUE, fillOpacity=0.5),
            list(color = colors[from:to])
          )
        )
      }
    })
    
    # TIL this is necessary in order to prevent the observer from
    # attempting to write to the websocket after the session is gone.
    session$onSessionEnded(paintObs$suspend)
  })
  
  # Show a popup at the given location
  showZipcodePopup <- function(business, lat, lng) {
    selectedBus <- allbus[allbus$business == business,]
    content <- as.character(tagList(
      tags$h4(as.character(selectedBus$fullname)),

      sprintf("Overall Review Score: %s", round(as.numeric(selectedBus$totalreviewscore),2)), tags$br(),
      sprintf("Overall Sample Size: %s", as.numeric(selectedBus$totalsamples)), tags$br(),
      sprintf("Service Review Score: %s", round(as.numeric(selectedBus$scorewsw),2)), tags$br(),
      sprintf("Non-Service Review Score: %s", round(as.numeric(selectedBus$scorewosw),2)), tags$br()
    ))
    map$showPopup(lat, lng, content, business)
  }

  # When map is clicked, show a popup with city info
  clickObs <- observe({
    map$clearPopups()
    event <- input$map_shape_click
    if (is.null(event))
      return()
    
    isolate({
      showZipcodePopup(event$id, event$lat, event$lng)
    })
  })
  
  session$onSessionEnded(clickObs$suspend)
  
  
  ## Data Explorer ###########################################
 
  observe({
    cities <- if (is.null(input$states)) character(0) else {
    filter(cleantable, State %in% input$states) %.%
    `$`('City') %.%
    unique() %.%
    sort()
    }
    stillSelected <- isolate(input$cities[input$cities %in% cities])
    updateSelectInput(session, "cities", choices = cities,
    selected = stillSelected)
  })

  observe({
    if (is.null(input$goto))
      return()
    isolate({
      map$clearPopups()
      dist <- 0.25
      zip <- input$goto$zip
      lat <- input$goto$lat
      lng <- input$goto$lng
      showZipcodePopup(zip, lat, lng)
      map$fitBounds(lat - dist, lng - dist,
        lat + dist, lng + dist)
    })
  })
  
  output$bustable <- renderDataTable({
    cleantable %>%
      filter(
        Pvalue >= input$minpval,
        Pvalue <= input$maxpval,
	is.null(input$states) | State %in% input$states,
	is.null(input$cities) | City %in% input$cities
      ) %>%
      mutate(Action = paste('<a class="go-map" href="" data-lat="', Latitude, '" data-long="', Longitude, '" data-zip="', Hash, '"><i class="fa fa-crosshairs"></i></a>', sep="")) %>%
      mutate(ReviewDiff = abs(NonServiceReviewScore - ServiceReviewScore)) %>%
	  select(
	    Name = Name,
	    MapLink = Action,
	    City = City,
	    State = State,
	    OverallReviewScore = OverallReviewScore,
	    OverallSampleSize = OverallSampleSize,
	    SRScore = ServiceReviewScore,
	    SRSampleSize = ServiceReviewSampleSize,
	    NSRScore = NonServiceReviewScore,
	    NSRSampleSize = NonServiceReviewSampleSize,
	    ReviewDiff = ReviewDiff,
	    Pvalue = Pvalue,
	    Qvalue = Qvalue
	  )
  })

})
