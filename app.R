# Generate Shiny dashboard about UNC collaborators and their emphases field

library(shiny)
library(tidyverse)
library(wordcloud2)
library(RColorBrewer)
library(scales)

# read in data
df <-  read_csv("prepShiny/keyword_rank.csv")
l <- df$collaborator %>% unique()
names(l) <- df$coll %>% unique()



# Define UI for app that draws a histogram and a data table----
ui <- fluidPage(
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      h2("Introduction"),
      p("This is a keyword analysis project based on 462 paper",
        " abstracts searched from", a("Pubmed.", href = "https://raw.githubusercontent.com/biodatascience/datasci611/gh-pages/data/p2_abstracts/pubmed_result.txt")),
      br(),
      p("From the panel below, you would be able to choose one of the ", 
        "top 10 institutions that UNC collaborated most frequently with in the field",
        " of life sciences and biomedical topics "),
      br(),
      hr(),
      p("Here you can choose one of the top 10 UNC collaborators"),
      
      selectInput("select", "Please choose a collaborator:",
                  choices = l, 
                  selected = "Duke University"),
      
      hr(),
      
      # fluidRow(column(5, verbatimTextOutput("value"))),
      
      sliderInput("freq",
                  "Minimum Frequency:",
                  min = 1,  max = 20, value = 2),
      sliderInput("max",
                  "Maximum Number of Words:",
                  min = 1,  max = 400,  value = 90)
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      tabsetPanel(
        tabPanel("Word Cloud", 
                 h2("The wordcloud"),
                 p("This is a wordcloud constituted with most frequently appeared keywords",
                   "in papers collaboratedly completed by UNC and the specified collaborator. ",
                   "The total number of times that keyword appeared ",
                   "would hover the graph if ", 
                   "you put your cursor over the keyword.",
                   " The more frequently collaborator researched that field with UNC,",
                   " the larger font that keyword would be. "),
                 br(),
                 p("The minimum frequency at which keywords show up and the maximum number of keywords displayed",
                   " in the graph could be adjusted from the left panel."),
                 
                 wordcloud2Output(outputId = "popPlot")
                 ), 
        tabPanel("Frequency Plot", 
                 h2("Frequency Plot"),
                 p("This is a frequency histogram describing the number of times and proportion of each keyword appeared ",
                   "in the collaboration of UNC and the specified collaborator."),
                 br(),
                 br(),
                 plotOutput(outputId = "popPlot1")
                 )
      )
    )
  )
)

# Define server logic required to draw a histogram ----

server <- function(input, output, session) {
  
  # Make the wordcloud drawing predictable during a session
  output$popPlot <- renderWordcloud2({
    df_1 <- df %>% 
      filter(collaborator == input$select) %>% 
      filter(keyword_freq >= input$freq) %>% filter(row_number(desc(keyword_freq)) <= input$max) %>%
      select(keyword, keyword_freq)
    set.seed(1234)
    wordcloud2(df_1, color = brewer.pal(8, "Dark2"), fontFamily = "Segoe UI")
  })
  
  # Frequency Plot
  output$popPlot1 <- renderPlot({
    # Collaboration strength
    times <- df %>%
      filter(collaborator == input$select) %>% 
      select(coll_strenth) %>% 
      unique()
    
    freq_str <- df %>%
      mutate(occurency_rate = keyword_freq/coll_strenth) %>%
      filter(collaborator == input$select) %>%
      filter(row_number(desc(occurency_rate)) <= 15)
    
    max_freq <- freq_str %>% select(occurency_rate) %>% max()
    
    freq_str %>%
      ggplot(aes(x = reorder(keyword,occurency_rate), y = occurency_rate)) +
      geom_bar(fill = "seagreen", stat = 'identity') +
      geom_label(aes(y = occurency_rate-0.045/0.75*max_freq, 
                     label = str_c(100*round(occurency_rate, 4), "% (n=", keyword_freq, ")" )), 
                 col = "beige",
                 alpha = 0,
                 fontface = "bold",
                 size = 4.3,
                 label.size = 0) +
      theme_minimal() +
      theme(title =element_text(size = 16, face='bold'),
            axis.text.x = element_text(size = 13, face = "bold"),
            axis.text.y = element_text(size = 15, face = "bold"),
            plot.margin = margin(0,.8, 0, .8, "cm")) +
      ylab("Keyword Frequency") +
      xlab("Keywords") +
      #ylim(c(0,0.72)) +
      labs(title = str_c("Subject Emphases of ", input$select, " \n -- Collaboration times: ", times, " out of 462 papers"),
           subtitle = str_c("Keywords and Their Frequencies from Paper Published Collaboratedly with UNC"),
           caption = "(Based on Data from PubMed)") +
      scale_y_continuous(breaks=seq(0, max_freq, 0.1),
                         labels = percent) +
      coord_flip() 
    
    
  })
}

shinyApp(ui = ui, server = server)
