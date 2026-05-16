
#Defining the log 
sink("question_3_tlg/q3_summary_log.txt", split = TRUE)

#Importing the required libraries

library(ggplot2)
library(tidyverse)
library(gtsummary)
library(pharmaverseadam)
library(dplyr)

#Reading the Adam data sets
adae <- pharmaverseadam::adae
adsl <- pharmaverseadam::adsl

#Applying the filter for TRTEMFL mentioned in the question
adae <- adae %>%
  filter(TRTEMFL=="Y")

#Building the summary table
summary_adae <- adae %>%
  tbl_hierarchical(
    #These go inside the rows
    variables = c(AESOC,AETERM),
    #This forms the columns
    by = ACTARM,
    #counting based on subject id
    id = USUBJID,
    #taking denominator of the count as the safety population
    denominator = adsl %>% filter(SAFFL == "Y"),
    overall_row = TRUE,
    label = "..ard_hierarchical_overall.." ~ "Treatment Emergent AEs"
  )
  
#Creating the html output file
summary_adae %>%
  as_gt() %>%
  gt::gtsave("question_3_tlg/ae_summary_table.html")


cat("Question 3 summary creation completed successfully.\n")
cat("Number of ADAE records after TEAE filtering:", nrow(adae), "\n")
cat("Treatment groups in analysis:\n")
print(unique(adae$ACTARM))

cat("Preview of final TLG:\n")
print(summary_adae)

#Creating log
sink()