### Analise de sobrevivencia

#Bibliotecas
library(tidyverse)
library(survival)
library(survminer)
library(eeptools)
library(openxlsx)
library(lubridate)
library(ggfortify)

#lembrar que se tiver grupos que mudam (cargo, por exemplo) tem que fazer cada pessoa virar um cargo q ela teve

#WD
setwd("~/github/survival-analysis")

#Functions
substrRight <- function(x, n){
 substr(x, nchar(x)-n+1, nchar(x))
}
substrLeft <- function(x, n){
 substr(x, 1, n)
}

#Colors
cores2 <- c("#C02A41","#184C99","#F7778A","#629BF0","#71B0B0","#4E807F")

#Bases
base <- read.csv('turnover.csv', header = TRUE, sep = ',', na.strings = c('', NA)) %>%
  mutate(gender = case_when(
    branch %in% c('fifth', 'first') ~ 'F',
    TRUE ~ 'M'  
  ))

# dataset from https://www.aihr.com/blog/applying-survival-analysis-reduce-employee-turnover-practical-case/ 
# exp – length of employment in the company
# event – event (1 – terminated, 0 – currently employed)
# branch – branch
# pipeline – source of recruitment

# Pode ser necessário calcular o tempo em bases que não apresentam essa informação,
# apenas datas de admissão de demissão
# base_completa_surv <- Base %>% 
# mutate(Admissão = as.Date(Admissão, origin = "1899-12-30"),
#         Demissão = as.Date(Demissão, origin = "1899-12-30"),
#         evento =  desligadoVol,
#         tempo = time_length(difftime(Demissão, Admissão), "years"),
#         ano = substrLeft(Admissão, 4))


base_completa_surv <- base_genero 

#Model
Time <- as.numeric(base_completa_surv$exp)
Event <- base_completa_surv$event
survival <- Surv(Time,Event)
Grupo <- base_completa_surv$gender


#Group model
model <- survival::survfit(survival ~ Grupo)
median <- summary(model)$table[,"median"]

#Entire base model
#model <- survival::survfit(survival  ~ 1)

survival_function <- ggsurvplot(model,conf.int = FALSE,
                      data = survival,
                      #surv.median.line = "hv",
                      palette = cores2,
                      ggtheme = theme_light())


survival_function$plot + 
 labs(x = "Tempo de empresa(Anos)",
      y = "Fração que continua na empresa",color = "", fill = "") + 
 geom_segment(y = 0.5, yend = 0.5,x = 0, xend = median[1],linetype = "dashed", size = 1, color = cores2[1])+
 geom_segment(y = 0, yend = 0.5,x = median[1], xend = median[1],linetype = "dashed", size = 1, color = cores2[1])+
 geom_segment(y = 0.5, yend = 0.5,x = 0, xend = median[2],linetype = "dashed", size = 1, color = cores2[2])+
 geom_segment(y = 0, yend = 0.5,x = median[2], xend = median[2],linetype = "dashed", size = 1, color = cores2[2])+
 annotate("label",x = median[1], label = round(median[1],1), y = 0.02, color = cores2[1])+
 annotate("label",x = median[2], label = round(median[2],1), y = 0.02, color = cores2[2])+
 theme(panel.grid = element_blank(),
       axis.text = element_text(color = "#4d4d4d", size = 8),
       axis.title = element_text(color = "#4d4d4d", size = 13, family = "Roboto"),
       #legend.position = "none"
 )




