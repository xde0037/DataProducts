 library(XLConnect)
 library(DT)
 library(lubridate)
 library(dplyr)
 library(shiny)
 library(shinyBS)
 library(ggplot2)
 library(ggrepel)
 library(rgdal)
 library(rgeos)
 library(shinyjs)
 
 # Adm Data was obtained here:
 # Get the old 2011 census administrative boundaries from the 
 # GADM database here: http://biogeo.ucdavis.edu/data/gadm2/shp/IND_adm.zip
 
#location="C:/DScience/Developing_Data_Products_C09/EX01/IND_adm"
## readOGR function reads the shape file with its dependent files
India0<-readOGR(dsn=".","IND_adm0", verbose=FALSE)  # Country boundaries, no states.
India1<-readOGR(dsn=".","IND_adm1", verbose=FALSE)  # all boundaries for states and UTs
India1$NAME_1 <- as.character(India1$NAME_1)
India1$NAME_1[grepl("Uttaranchal",India1$NAME_1)]="Uttarakhand"
India1$NAME_1[grepl("Orissa",India1$NAME_1)]="Odisha"
# State List and Union Territories India
df0<-read.csv("India_Population_StateWise_2015.CSV")
India_Pop_DF<-df0[36,]   # total country population as of 2015
State_List<-as.vector(df0[1:35,"STATE"])   #[1],[2] etc..
df0$STATE<-as.character(df0$STATE)  # un-factor
State_List<-c(toupper(State_List),'ALL')
dist0<-read.csv("all_india_PO_list_without_APS_offices_ver2_lat_long.csv")
state_dist0<-dist0[,c("statename","Districtname")]  #get the state/district pair, 2:154798
state_dist<-unique(state_dist0)
## st_dist[st_dist$statename=='GUJARAT',]  #displays all districts of GUJARAT
## read other 2 data files for economic data and forest-cover data.
Forest0<-read.csv(file="Recorded_Forest_Areas_in_States_and_UTs.csv", stringsAsFactors = FALSE)
colnames(Forest0)<-c("state","statearea","forestarea2005","reserved","protected","unclassed",
                        "totalforestarea","forestareapercent")
India_Forest_Pct<-Forest0[36,]
Forest0$state = as.character(Forest0$state)
IndiaForest<-India1
IndiaForest@data<-merge(IndiaForest@data,Forest0,by.x="NAME_1",by.y="state")

Econ0<-read.csv(file="India_Statewise_Econ_Data_2014.csv", stringsAsFactors = FALSE)
India_Tot_Econ<-Econ0[33,]
Econ0$STATE = as.character(Econ0$STATE)
IndiaEcon<-India1
IndiaEcon@data<-merge(IndiaEcon@data,Econ0,by.x="NAME_1",by.y="STATE")

 shinyServer(function(input, output,session) { 
 MapOpn<-0
 
  data01 <- reactive({
 #   validate(
 #     need(input$SelState != "", "StateName is NULL")
 #   )
 #   get(input$SelState,"ALL")
  })

   # Drop-down State List
   output$State <- renderUI({ 
     selectInput("SelState", "State", as.list(State_List), selected = "ALL")
   }) 

   output$text <- renderUI({
         str0<- "Use Summary Tab to view more details about following Selection:"
		 str1<- paste("->State : ", input$SelState," Dist: ")
		 str2<-paste(str1,ifelse(((!is.null(input$DList)) && input$SelState != 'ALL'),input$DList,"-"))
		 str3 <- paste("->Data Selected :", input$dataset)
		 HTML(paste(str0,str2,str3,sep='<br/>'))
  })
  
  output$SummaryCountry <- renderUI({
                str0<-"India Country Snapshot : "
	   		    state_row0<-India_Pop_DF
			    str1<-paste0("India Total Population-2015: ",as.character(state_row0$POPULATION),'<br/>')
			    str1<-paste0(str1,"Population Urban%: ",as.character(state_row0$URBAN),'<br/>')
			    str1<-paste0(str1,"Population Rural%: ",as.character(state_row0$RURAL),'<br/>')
				str1<-paste0(str1,"Decadal Groth %: ",as.character(state_row0$DECADAL_GROWTH),'<br/>')
			    str1<-paste0(str1,"Population Compares To Country: China (which is rank 1)",'<br/>') 	 
			    str5<-strOut()
			    HTML(paste(str0, str1, str5, sep = '<br/>')) 
  })

  output$SummaryText <- renderUI({
         str0<-paste("State : ",input$SelState," Snapshot : ")
  		 if ( (!is.null(input$SelState) && input$SelState == 'ALL')) {
              str0<- "Select a State to view its Snapshot"
			  HTML(str0)
		 }
		 if ( (!is.null(input$SelState) && input$SelState != 'ALL')) {
             str1 <- paste("State : ", input$SelState)
			 str2<-NULL
			 if ( (!is.null(input$DList) && input$DList != 'ALL')) {
			    str2<-paste("District : ", input$DList)
			 }
			 str3<-"State Level Data : "
			 str4<-"Population Data Rows not found"
			 state_row0 <- filter(df0,toupper(df0$STATE) %in% input$SelState)    #pop
			 if (!(is.data.frame(state_row0) && nrow(state_row0)==0)) {
			    str4<-paste0("Population Total: ",as.character(state_row0$POPULATION),'<br/>')
			    str4<-paste0(str4,"Population Urban%: ",as.character(state_row0$URBAN),'<br/>')
			    str4<-paste0(str4,"Population Rural%: ",as.character(state_row0$RURAL),'<br/>')
			    str4<-paste0(str4,"Population % of Total: ",as.character(state_row0$PCT_OF_TOTAL),'<br/>')
			    str4<-paste0(str4,"Population Compares To Country: ",state_row0$COMPARE_COUNTRY,'<br/>')           				
			 }
			 str5<-strOut()
			 HTML(paste(str0,str1, str2,str3, str4, str5, sep = '<br/>'))
		 }			 
  })
     output$text1 <- renderText({
	       state_row0 <- filter(df0,toupper(df0$STATE) %in% input$SelState)
		   str1<-paste("Population Of",'<br/>')
		   str1<-paste(str1,input$SelState,":",'<br/>')
		   str1<-paste(str1,as.character(state_row0$POPULATION))
		   HTML(str1,sep='<br/>')
	 })
   
  #  Drop-down selection box for Districts for a State
   output$District <- renderUI({ 
     # did not work : District_List <- state_dist[state_dist$statename %in% input$SelState,]
     if ( (!is.null(input$SelState)) && input$SelState != 'ALL') {
	    District_List <- filter(state_dist,state_dist$statename %in% input$SelState)
	    # as/list did not work below.
        selectInput("DList", "District", as.vector(District_List$Districtname), selected = "ALL")
	 }
   }) 
   
   # DataSet Selection
   output$DataSet <- renderUI({
     if ( (!is.null(input$SelState)) && input$SelState != 'ALL') {
	    DataSet_List <- c("State_Population","State_Forest_Coverage","State_Economic_Indicators")
        selectInput("dataset", "DataSet List", as.vector(DataSet_List), selected = "Population--State") 
	 }
	 else
	 {
	    DataSet_List <- c("Country_Population","Country_Forest_Coverage","Country_Economic_Indicators")
        selectInput("dataset", "DataSet_List", as.vector(DataSet_List), selected = "Population--Country") 
	 }
   })
   
# subset data as per user input here for graphs we could make this common across other reactive fun also

 output$MapOption <- renderUI({
       if ( (!is.null(input$SelState) && input$SelState != 'ALL')) {
	       l1<-paste0("Show ",input$SelState, "'s Separate Map")
		   l2<-paste0("Show ",input$SelState," On India's Map")
		   OList<-c(l2,l1)
           selectInput("op1", "State Map Options", as.vector(OList)) #grepl("India", chars) 		   
	   }
 })

 output$chkbox3 <- renderUI({
     if ( (!is.null(input$SelState) && input$SelState != 'ALL')) {
	     # hide(updateCheckboxInput(session, "chkbox3", label = NULL))
		 hide("chkbox3")
	 }
	 else
	 {
	    checkboxInput(inputId = "chkbox3", label = "Show State Boundaries", value=FALSE)
	 }
 })

M1<-reactive({
	   if (!is.null(input$op1) && grepl("India", input$op1)==TRUE) {
	      MOpn<-0
	   }
	   else {
	       MOpn<-1
	   }
	   c1<-as.numeric(MOpn)
	   return(c1)
})

# all inclusive reactive
strOut <- reactive({
	   # ALL States
	   str1<-NULL    #avoid any missing 
       MapOpn<-M1()
       if (!is.null(input$SelState) && input$SelState == 'ALL') {
	   	   if ( (!is.null(input$dataset)) && input$dataset == 'Country_Population') {
	   		    state_row0<-India_Pop_DF
		        str1<-paste0("State : ",input$SelState,", Population: ", as.character(state_row0$POPULATION),".")
				return(str1)				
           }
	       if ( (!is.null(input$dataset)) && input$dataset == 'Country_Forest_Coverage') {
		          state_row0<-India_Forest_Pct
		          str1<-paste0("India : Total Forest Area Coverage % : ", as.character(state_row0$forestareapercent),".")
				  return(str1)
		   }
	       if ( (!is.null(input$dataset)) && input$dataset == 'Country_Economic_Indicators') {
                  state_row0 <- India_Tot_Econ		   	   	  
		          str1<-paste0("India : Total Industry Output-2014(INR Crores): ",as.character(state_row0$Industry),".")
				  return(str1)
		   }   
	   }
	   # single state, stand alone
       if ( MapOpn==1 && !is.null(input$SelState) && input$SelState != 'ALL') {
	       if ( (!is.null(input$dataset)) && input$dataset == 'State_Population') {
		   	   	  state_row0 <- filter(df0,toupper(df0$STATE) %in% input$SelState)
		          str1<-paste0("State : ",input$SelState,", Population: ", as.character(state_row0$POPULATION),".")
				  return(str1)
		   }
	       if ( (!is.null(input$dataset)) && input$dataset == 'State_Forest_Coverage') {
		   	   	  state_row0 <- IndiaForest@data$forestareapercent[which(toupper(IndiaForest$NAME_1) %in% input$SelState )]
		          str1<-paste0("State : ",input$SelState,", Forest Area Coverage % : ",as.character(state_row0),".")
				  return(str1)
		   }
	       if ( (!is.null(input$dataset)) && input$dataset == 'State_Economic_Indicators') {
                  state_row0 <- IndiaEcon@data$Industry[which(toupper(IndiaEcon$NAME_1) %in% input$SelState )]		   	   	  
		          str1<-paste0("State : ",input$SelState,", Industry Output-2014(INR Crores): ",as.character(state_row0),".")
				  return(str1)
		   }   
	   }
	   # single state on full map
       if (MapOpn==0 && !is.null(input$SelState) && input$SelState != 'ALL') {
	       if ( (!is.null(input$dataset)) && input$dataset == 'State_Population') {
		   	   	  state_row0 <- filter(df0,toupper(df0$STATE) %in% input$SelState)
		          str1<-paste0("India ( State : ",input$SelState,", Population: ",as.character(state_row0$POPULATION)," )")
				  return(str1)
		   }
	       if ( (!is.null(input$dataset)) && input$dataset == 'State_Forest_Coverage') {
		   	   	  state_row0 <- IndiaForest@data$forestareapercent[which(toupper(IndiaForest$NAME_1) %in% input$SelState )]
		          str1<-paste0("India ( State : ",input$SelState,", Forest Area Coverage % : ",
				  as.character(state_row0)," )")
				  return(str1)
		   }
	       if ( (!is.null(input$dataset)) && input$dataset == 'State_Economic_Indicators') {
                  state_row0 <- IndiaEcon@data$Industry[which(toupper(IndiaEcon$NAME_1) %in% input$SelState )]		   	   	                    		   	   	  
		          str1<-paste0("India ( State : ",input$SelState,", Industry Output-2014(INR Crores): ",
				  as.character(state_row0)," )")
				  return(str1)
		   }
       }	
	   if (is.null(str1)) {
  	        str1<-"NULL" 
			return(str1)
	   }
	   else
	   {
           str1<-(ifelse((!(is.data.frame(state_row0) && nrow(state_row0)==0)),str1,NULL))
           return(str1)
		}
})

output$text11 <- renderPrint ({
         print(class(input$SelState))
		 print(input$SelState)
		 print('\n')
		 print(!is.null(input$SelState))
		 print('\n')
		 print(ifelse(input$SelState=='ALL','all','problem'))
		 print((!is.null(input$SelState) && input$SelState == 'ALL'))
		 print('\r')
		 print(input$dataset)
		 print((!is.null(input$dataset) && input$dataset == 'Country_Population'))
		 print(data01())

})
# Display the Plot
output$plot <- renderPlot ({
       # default map
	   MapOpn<-M1()
	   d1<-grepl("India",as.character(input$op1))
       if (!is.null(input$chkbox3) && input$chkbox3 == FALSE && !is.null(input$SelState) && input$SelState == 'ALL') {
           plot(India0)
		   title("India (Adm Boundary)")
	   }
       # all states on country map
       if (!is.null(input$chkbox3) && input$chkbox3 == TRUE && !is.null(input$SelState) && input$SelState == 'ALL') {
           plot(India1)
		   title("India ( all states adm )")
	   }
	   # single state
       if (!is.null(input$SelState) && input$SelState != 'ALL') {
	            if ( !d1 ) {
	              str1<-strOut()
				  str1<-(ifelse(!is.null(str1),str1,input$SelState))				  
				  plot(India1[toupper(India1$NAME_1)==input$SelState,],col="forestgreen")
				  id1<-India1$ID_1[grepl(input$SelState,toupper(India1$NAME_1))]
				  centroids <- gCentroid(India1, byid=TRUE)
                  centroidLons <- coordinates(centroids)[id1,1]
                  centroidLats <- coordinates(centroids)[id1,2]
	              title(str1)
                  text(centroidLons, centroidLats, labels=input$SelState, col="black", cex=.8)
				}
				# single state on India map
				if ( d1 ) {
  	               str1<-strOut()
				   str1<-(ifelse(!is.null(str1),str1,input$SelState))
			       plot(India0)
		           plot(India1[toupper(India1$NAME_1)==input$SelState,],add=TRUE,col="forestgreen")
			       title(str1)				
				}
	   }
  }, height = 640, width = 600)

 }) #end function,shinyServer
 