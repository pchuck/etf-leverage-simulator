library(shiny)

# ui - leveraged etf simulator
shinyUI(pageWithSidebar(
  headerPanel("Leveraged ETF Returns"),
    sidebarPanel(
        h3('Underlying Index'), 
        selectizeInput("symbol", "Symbol", selected="^IXIC",
                       choices = list( # (better would be to populate via API)
                           Indices = c(
                               '^DJI (Dow Jones Industrial Average)'='^DJI',
                               '^IXIC (NASDAQ Composite)'='^IXIC',
                               '^GSPC (S&P 500)'='^GSPC',
                               '^RUT (Russell 2000 Index)'='^RUT',
                               '^MID (S&P Mid-cap 400 Index)'='^MID',
                               'IXE (S&P Energy Select Sector Index)'='IXE',
                               'IXB (S&P Materials Select Sector Index)'='IXB',
                               'IXV (S&P Health Care Sector Index)'='IXV',
                               'RMZ (MSCI US REIT Index)'='RMZ',
                               'IXT (S&P Technology Sector Index)'='IXT',
                               '^SOX (PHLX Semiconductor Index)'='^SOX',
                               '^VIX (S&P 500 Volatility Index)'='^VIX',
                               '^TNX (CBOE 10-Year T Note)'='^TNX',
                               '^TYX (CBOE 30-Year T Note)'='^TYX'
                           ),
                           Securities = c(
                               'AAPL (Apple Inc.)'='AAPL',
                               'MSFT (Microsoft Corporation)'='MSFT',
                               'AMZN (Amazon.com Inc.)'='AMZN',
                               'GE (General Electric Company)'='GE',
                               'BRK-A (Berkshire Hathaway Inc.)'='BRK-A', 
                               'GLD (Spider Gold Trust)'='GLD',
                               'FTABX (Fidelity Tax-Free Bond)'='FTABX'
                           )),
                       multiple = FALSE),
        dateInput("startDate", "Start Date: ", value="2005-01-01"),
        dateInput("endDate", "End Date: "),
        actionButton("fetchButton", "Fetch Data"),

        h3('ETF Parameters'),
        sliderInput("leverage", "Leverage Multiplier", 
                    value=2.0, min=1.0, max=4.0, step=0.5),
        sliderInput("expense", "Expense Ratio %", 
                    value=1.0, min=0.0, max=3.0, step=0.10)
    ),
    mainPanel(
        h2('Simulation'),
        plotOutput('simulationPlot'),
        textOutput('messages')
    )
))

