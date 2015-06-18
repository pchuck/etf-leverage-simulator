library(shiny)
library(ggplot2)
library(reshape2)
library(quantmod)

# server - leveraged etf simulator
shinyServer(
    function(input, output, session) {
        source <- "yahoo" # source for underlying daily closing prices
        tradingDays <- 252 # average number of trading days in a year
        options("getSymbols.warning4.0"=FALSE)
        
        v <- reactiveValues(xts.daily = NULL, symbol = NULL, 
                            endDate = NULL, startDate = NULL,
                            leveragedReturn = NULL, actualReturn = NULL)

        # fetch daily returns for the underlying index or security
        observeEvent(input$fetchButton, {
            cat(paste("fetching data for ", input$symbol, "..\n", sep=""))
            v$symbol <- input$symbol
            v$startDate <- input$startDate
            v$endDate <- input$endDate
            v$xts.daily <- NULL
            try( # use quantmod to fetch historical data
                v$xts.daily <- getSymbols(Symbols=input$symbol, src=source,
                                          from=v$startDate, to=v$endDate,
                                          # split-adjust historical data
                                          auto.assign=FALSE, adjust=TRUE)
            )
        })
        
        # simulation
        output$simulationPlot <- renderPlot({
            if(is.null(v$xts.daily)) return() # bail if data not yet loaded
            expenseRatio <- input$expense / 100 # convert percentage to factor
            dailyExpense <- expenseRatio / tradingDays # convert exp to daily

            df.daily <- as.data.frame(v$xts.daily)
            # simplify the row names
            colnames(df.daily) <- # rename close to 'actual' (v. 'simulated')
                c("Open", "High", "Low", "Actual", "Volume")
            df.daily$Date <- as.Date(rownames(df.daily)) # give date a column
            df.daily$Delta <- Delt(df.daily$Actual)[, 1] # daily price deltas
            df.daily$Simulated <- df.daily$Actual[1] # seed the leverage col

            # calculate daily leveraged returns
            for(i in 2:nrow(df.daily)) { 
                previous <- df.daily[i - 1, ]$Simulated # previous value
                delta <- df.daily[i, ]$Delta # closing price delta
                df.daily[i, ]$Simulated = # calculated, next leveraged price
                    previous + previous * delta * input$leverage -
                        previous * dailyExpense
            }

            # render a plot of actual vs. simulated returns
            title <- paste(v$symbol, ": Actual vs. Simulated ",
                           input$leverage, "x Leverage", sep="")
            range <- paste(v$startDate, " to ", v$endDate, sep="")
            df.melted <- melt(df.daily, id.vars=c("Date"))
            df.melted <- df.melted[df.melted$variable == 'Actual' |
                                   df.melted$variable == 'Simulated', ]
            colnames(df.melted) <- c("Date", "Price", "Value")
            ggplot(df.melted, aes(x=Date, y=Value, color=Price)) +
                geom_line() + 
#                stat_smooth(method="loess", alpha=0.5, level=0.75) + 
                xlab(paste("Date (", range, ")", sep="")) + 
                ylab("Closing Price") + ggtitle(title)
        })

        # validation
        output$messages <- renderText({
            if(as.Date(input$startDate) >= as.Date(input$endDate)) {
                paste("End Date must be after Start Date!"); return }
            if(input$fetchButton < 1) # not yet fetched
                paste("Select a symbol and click 'Fetch Data'")
            else if(is.null(v$xts.daily)) # fetched, but failed
                paste("An error occurred. ",
                      "Try another symbol and click 'Fetch Data'.")
        })
    }
)

