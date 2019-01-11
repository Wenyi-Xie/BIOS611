FROM rocker/tidyverse:3.5

RUN Rscript -e "install.packages('wordcloud2')"

RUN export ADD=shiny && bash /etc/cont-init.d/add

