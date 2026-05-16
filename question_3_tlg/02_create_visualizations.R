#Defining the log 
sink("question_3_tlg/q3_graphs_log.txt", split = TRUE)


#importing required libraries
library(pharmaverseadam)
library(ggplot2)
library(dplyr)

#reading the required data sets
adae <- pharmaverseadam::adae
adsl <- pharmaverseadam::adsl

#filtering the treatment exposure records
adae <- adae %>%
  filter(TRTEMFL=="Y")

# Visualization 1 - Stacked Bar Chart 
ggplot(adae, aes(x=ACTARM,fill = AESEV))+
  geom_bar(position = "stack")+
  labs(title = "AE severity distribution by treatment",
       x = "Treatment Arm",
       y = "Count of AEs",
       fill = "Severity/Intensity"
       )+
  theme_minimal()

#Saving the visualization 1
ggsave("question_3_tlg/severity_dist.png")


#Visualization 2 Top 10 Most frequent Adverse Events

#Creating a table with number of patients in each AE and taking top 10 
ae_count <- adae %>%
  group_by(AETERM) %>%
  summarise(n_patients = n_distinct(USUBJID), 
            .groups = "drop") %>%
  arrange(desc(n_patients)) %>%
  slice_head(n=10)

# Creating safety population
sp <- adsl %>%
  filter(SAFFL == "Y")

#counting the safety population
total_safety_pop <- n_distinct(sp$USUBJID)

#Finding percentage and confidence intervals
ae_count <- ae_count %>%
  mutate(pct = (n_patients/total_safety_pop)*100) %>%
  rowwise() %>%
  mutate(
    lower_ci = binom.test(n_patients, total_safety_pop)$conf.int[1] * 100,
    upper_ci = binom.test(n_patients, total_safety_pop)$conf.int[2] * 100
  ) %>%
  ungroup()
  

# Creating the visualization
top10_ae_plot <- ggplot(ae_count, aes(x = pct, y = reorder(AETERM, pct))) +
  geom_point() +
  geom_errorbar(aes(xmin = lower_ci, xmax = upper_ci), height = 0.2) +
  labs(
    title = "Top 10 Most Frequent Adverse Events",
    subtitle = paste0("n = ", total_safety_pop, " subjects; 95% Clopper-Pearson CIs"),
    x = "Incidence Rate (%) with 95% CI",
    y = "Adverse Event"
  ) +
  theme_minimal()

#Saving the visualization 2
ggsave("question_3_tlg/top10_ae.png")

#Logs
cat("Question 3 visualizations completed successfully.\n\n")

cat("Number of TEAE records:\n")
print(nrow(adae))

cat("\nSafety population count:\n")
print(total_safety_pop)

cat("\nTop 10 adverse events:\n")
print(ae_count)

cat("\nVisualization 1 saved as:\n")
print("question_3_tlg/severity_dist.png")

cat("\nVisualization 2 saved as:\n")
print("question_3_tlg/top10_ae.png")

#Creating log file
sink()

