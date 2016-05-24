library(shiny)
library(shinyBS)

shinyUI(pageWithSidebar(  
 
   headerPanel(h3("Spatial Data Visualization")), 
   # dynamic UI can be done with uiOutput
   sidebarPanel( 
       tags$style(type='text/css', '#HText {background-color: rgba(0,0,255,0.10); color: green;}'),
       helpText(HText<-"Spatial Visualization (India) as per selected State/Data.(APP might be slow at first time)"),
     uiOutput("State"), 
	 uiOutput("District"),
	 uiOutput("DataSet"),
	 br(),
	 uiOutput("MapOption"),
	 tags$style(type='text/css', '#text {background-color: rgba(255,255,0,0.40); color: green;}'),
	 htmlOutput("text")
#	 uiOutput("chkbox1"),
#	 uiOutput("chkbox2")
    ),
   mainPanel( 
            tags$style(type="text/css",
                            ".shiny-output-error { visibility: hidden; }",
                            ".shiny-output-error:before { visibility: hidden; }"),
      tabsetPanel(
        tabPanel("Maps", plotOutput("plot",width="100%"),
		          uiOutput("chkbox3")
		        ), 
        tabPanel("State_Summary", 
		         tags$style(type='text/css', '#SummaryText {background-color: rgba(255,255,0,0.40); color: darkbrown;}'),
		         htmlOutput("SummaryText")
		), 
        tabPanel("India_Snapshot", 
		         tags$style(type='text/css', '#SummaryText {background-color: rgba(100,255,0,0.40); color: darkorange;}'),
		         htmlOutput("SummaryCountry")
		), 		
        tabPanel("About",   suppressWarnings(includeMarkdown("about.md")))
#		,tabPanel("TESTDATA",textOutput("text11"))   # added to do live debugging
   ))   ##mainPanel and tabsetPanel
)) ##shinyUI and pageWithSidebar
