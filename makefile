# Coursera, Developing Data Products, Final Project
#
# shiny application and slidify presentation
#

# tmuxinator an R dev environment
create_env:
	tmuxinator start r-sandbox

render:
	./R/rmdToHtml.R dp_project

run_app:
	R -e "shiny::runApp('../etf-leverage-simulator', display.mode='showcase')"

deploy_app:
	R -e "shinyapps::deployApp('../etf-leverage-simulator')"

slidify:
	R -e "slidify::slidify('index.Rmd')"

view_slides:
	R -e "browseURL('index.html')"

# remove generated files
clean:
	rm -f $(SRC).csv
	rm -f *.html *.md
	rm -rf figure/

