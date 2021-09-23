library(shiny)
library(shinythemes)

# Define UI for application that predicts the next word
shinyUI(
    fluidPage(

    # Application title
    titlePanel("Capstone Project - Predict the Next Word"),

    # Sidebar with a slider input for number of bins
    navbarPage("Menu",
        tabPanel("Prediction",
            sidebarLayout(
                sidebarPanel(
                    
                    textInput("userinput","Enter your text, then click submit",value = ""),
                    submitButton("Submit"),
                    
            ),
            mainPanel(
                
                h3("Your sentence:"),
                verbatimTextOutput("usertext"),
                h3("Next word predictions(from highest to lowest)"),
                h4("The first word:"),
                verbatimTextOutput("firstword"),
                h4("The second word:"),
                verbatimTextOutput("secondword"),
                h4("The third word is:"),
                verbatimTextOutput("thirdword"),
                
            )
          )    
        ),
        tabPanel("Instructions",
             h3("Instructions:"),
             br(),
             div("1. Choose the Prediction tab in the menu."),
             div("2. Enter your text and then click submit"),
             div("3. The top three predicted next words will be displayed to the right."),
             br(),
             div("If no prediction is possible based on the datasets, you`ll get NA."),
             br()
         ),
        tabPanel("About App",
           h3("About this App"),
           br(),
           div("This app is a Shiny app that uses text prediction algorithms to predict the next word
            based on text entered by a user. It displays the top three most frequenct next words in order, from highest to lowest"),
           br(),
           div("The predictive model and algorithm used in this app was developed as part of coursera's data science capstone project"),
           br(),
           div("Find attached the code that contains the algorith used for text prediction:",
           a(target = "_blank", 
             href="https://www.coursera.org/specializations/jhu-data-science", 
                                       "Prediction Code")),
           br(),
           br(),
           br(),
           img(src = "pugzy1.png",align = "center")
         
           )
       )
    )
)
