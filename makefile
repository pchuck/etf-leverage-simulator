# etf-leverage-simulator
#
# Coursera, Developing Data Products, Final Project
# shiny application and slidify presentation
#

# tmuxinator an R dev environment
create_env:
	tmuxinator start r-sandbox

# install prerequisite packages
prereqs:
	R -e "install.packages(c('devtools', 'shiny'), repos='http://cran.us.r-project.org'); devtools::install_github('rstudio/shinyapps')"
	R -e "devtools::install_github('ramnathv/slidify'); devtools::install_github('ramnathv/slidifyLibraries');"

# run shiny server locally
run_app:
	R -e "shiny::runApp('../etf-leverage-simulator', display.mode='showcase')"

# deploy to shinyapps.io
deploy_app:
	R -e "shinyapps::deployApp('../etf-leverage-simulator')"

# slides (apply on branch gh-pages)
slidify:
	R -e "slidify::slidify('index.Rmd')"

# view slides locally
view_slides:
	R -e "browseURL('index.html')"

# remove generated files
clean:
	rm -f $(SRC).csv
	rm -f *.html *.md
	rm -rf figure/

