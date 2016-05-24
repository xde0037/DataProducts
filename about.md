
  #### Project : Developing Data Products Course: JHU Data Science, Coursera<br/>
  #####  Chetan Bhatt<br/>
  ####     Spatial Data Query and Visualization

  This shiny application project takes GADM data as available online for all countries.
  Here the country INDIA has been selected. There was very little manual work done to
  arrange data such as STATE and District List, other than that, all data has been
  used "as available" from the web sites as mentioned in reference below.
  We start with displaying the country map and then application allows users to select
  either whole country and view various data associated with it such as population,
  forest area, economic(gdp) etc.. Application also allows to select a particular
  state and view its summary indicators as well as the maps with district boundaries.
  
  All plots and summaries are dynamically generated through Shiny and R language features.
  UI section also gets drop-down from the data dynamically.
  
  The GitHub Repo for this project is here: https://github.com/xde0037/DataProducts

  Note for reproducibility : Simply take code and data files and keep all in one folder to reproduce.<br/>
  DownLoad these files, along with data files from data folder to reproduce : <br>
    ---->> ui.R, server.R, about.md<br/>
  <br/>
  Data Files for India as used in this project: please check data folder on GitHub.
  References:<br/>
  Government of India's Newly launched data site : data.gov.in<br/>
  GADM all countries' admin boundaries : gadm.org<br/>
  Please note that Economic data is missing for a few states.<br/>
  ==> Please acknowledge JHU Data Science, Coursera and this Project In case this project in whole or part is used elsewhere.
	
	
