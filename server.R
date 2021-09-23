


library(shiny)
source("predictionmodel_stop.R")

# Server logic required to predict next word:
shinyServer(
    function(input, output) {
        # get sentence:
        output$usertext <- renderText(input$userinput)
        # predict the next words:
    
        output$firstword <- renderText(predict.with.stop(input$userinput)[1])
        output$secondword <- renderText(predict.with.stop(input$userinput)[2])
        output$thirdword <- renderText(predict.with.stop(input$userinput)[3])
})
