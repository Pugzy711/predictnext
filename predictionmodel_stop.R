library(ggplot2)
library(NLP)
library(tm)
library(RWeka)
library(data.table)
library(dplyr)
library(lexicon)

data("profanity_alvarez")

# load the n-gram frequencies 
unigrams <- readRDS("unigrams_stop.rds")
bigrams <- readRDS("bigrams_stop.rds")
trigrams <- readRDS("trigrams_stop.rds")
quadgrams <- readRDS("quadgrams_stop.rds")

# transform terms to individual columns for all n-grams:
quadragram_split <- strsplit(quadgrams$term,split=" ")
quadgrams <- transform(quadgrams, first = sapply(quadragram_split,"[[",1),
                       second = sapply(quadragram_split,"[[",2),
                       third = sapply(quadragram_split,"[[",3), 
                       fourth = sapply(quadragram_split,"[[",4))

trigram_split <- strsplit(trigrams$term, split = " ")
trigrams <- transform(trigrams, first = sapply(trigram_split,"[[",1),
                      second = sapply(trigram_split,"[[",2),
                      third = sapply(trigram_split,"[[",3))


bigram_split <- strsplit(bigrams$term, split = " ")
bigrams <- transform(bigrams, first = sapply(bigram_split,"[[",1),
                     second = sapply(bigram_split,"[[",2))

# function to clean input so it's same format as databases 
cleanInput.stop <- function(input) {
    
    if (input == "" || length(input)== 0) {
        return("")
    }
    
    input <- tolower(input)
    
    # remove URL, email addresses, Twitter handles and hash tags
    input <- gsub("(f|ht)tp(s?)://(.*)[.][a-z]+", "", input, ignore.case = FALSE, perl = TRUE)
    input <- gsub("\\S+[@]\\S+", "", input, ignore.case = FALSE, perl = TRUE)
    input <- gsub("@[^\\s]+", "", input, ignore.case = FALSE, perl = TRUE)
    
    # remove numbers
    input <- gsub("[0-9](?:st|nd|rd|th)", "", input, ignore.case = FALSE, perl = TRUE)
    
    # remove profane words
    input <- removeWords(input, "profanity_alvarez")
    
    # remove punctuation
    input <- gsub("[^\\p{L}'\\s]+", "", input, ignore.case = FALSE, perl = TRUE)
    
    # remove punctuation (leaving ')
    input <- gsub("[.\\-!]", " ", input, ignore.case = FALSE, perl = TRUE)
    
    # trim leading and trailing whitespace
    input <- gsub("^\\s+|\\s+$", "", input)
    input <- stripWhitespace(input)
    input <- unlist(strsplit(input, " "))
    
    # return blank if left with empty input after editing the text
    if (input == "" || length(input)== 0) {
        return("")
    }
    return(input)
}


## find match function:
findmatch <- function(words, ngrams) {
    
    # split words and unlist if words is character otherwise ignore
    words <- unlist(strsplit(words, " "))
    
    # quadgram (and higher)
    if (ngrams > 3){
        # get the last 3 words from input
        words4 <- tail(words, 3)
        wordmatch <- head((quadgrams[quadgrams$first==words4[1] 
                                   & quadgrams$second == words4[2]
                                   & quadgrams$third == words4[3], ]),3)
        # wordmatch <- wordmatch[order(- wordmatch$freq),]
        print("quadgrams -------")
        print(wordmatch)
        n <- nrow(wordmatch)
        if (n == 0) {
            return(findmatch(words, ngrams - 1))
        } else if (n == 1){
            return(wordmatch$fourth)
        } else if (n == 2){
            return(wordmatch$fourth[1:2])
        } else if (n >= 3){
            return(wordmatch$fourth[1:3])
        }
    }
    # trigram
    if (ngrams == 3) {
        # get the last two words 
        words3 <- tail(words, 2)
        wordmatch <- head((trigrams[trigrams$first==words3[1] 
                                     & trigrams$second == words3[2], ]),3)
        n <- nrow(wordmatch)
        print("trigrams -------")
        print(wordmatch)
        if (n == 0) {
            return(findmatch(words, ngrams - 1))
        } else if (n == 1){
            return(wordmatch$third)
        } else if (n == 2){
            return(wordmatch$third[1:2])
        } else if (n >= 3){
            return(wordmatch$third[1:3])
        }
    }
    
    # bigram 
    if (ngrams == 2) {
        
        words2 <- words[length(words)]
        wordmatch <- head((bigrams[bigrams$first==words2, ]),3)
        n <- nrow(wordmatch)
        print("bigrams -------")
        print(wordmatch)
        if (n == 0) {
            return(findmatch(words, ngrams - 1))
        } else if (n == 1){
            return(wordmatch$second)
        } else if (n == 2){
            return(wordmatch$second[1:2])
        } else if (n >= 3){
            return(wordmatch$second[1:3])
        }
    }
    # unigram: 
    if (ngrams == 1){
        if (words == "" || length(words)== 0) {
            wordmatch <- c("", "", "")
        }
        else{
            wordmatch <- unigrams[1:3, "term"]
            print("unigrams -------")}
        return(wordmatch)
    }
}

## clean input and get ngram count 
predict.with.stop <- function(sentence) {
    
    words <- cleanInput.stop(sentence)
    n <- length(words)
    
    if (words == "" || n == 0) {
        nextwords <- c("", "", "")
    } 
    else if (n == 1 || n ==2) {
        nextwords <- findmatch(words, ngrams = n + 1)
    } 
    else if (n > 2) {
        nextwords <- findmatch(words, ngrams = 4)
    }
    
    return(nextwords)
}
