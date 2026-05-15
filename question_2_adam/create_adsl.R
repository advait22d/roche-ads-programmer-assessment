#Defining the log 
sink("question_2_adam/q2_log.txt", split = TRUE)

#Importing the required libraries
library(metacore)
library(metatools)
library(pharmaversesdtm)
library(admiral)
library(xportr)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)

#initializing the input data
dm <- pharmaversesdtm::dm
vs <- pharmaversesdtm::vs
ex <- pharmaversesdtm::ex
ds <- pharmaversesdtm::ds
ae <- pharmaversesdtm::ae
suppdm <- pharmaversesdtm::suppdm

#Replacing the missing blanks with NA wherever required
dm <- convert_blanks_to_na(dm)
vs <- convert_blanks_to_na(vs)
ex <- convert_blanks_to_na(ex)
ds <- convert_blanks_to_na(ds)
ae <- convert_blanks_to_na(ae)
suppdm <- convert_blanks_to_na(suppdm)

#Creating the combination of the primary and the supplement
dm_suppdm <- combine_supp(dm,suppdm)

#Starting to create adsl with the variables from DM data set
adsl <- dm %>%
  mutate(
    AGEGR9 = case_when(
      AGE<18 ~ "<18",
      AGE>=18 & AGE<=50 ~ "18 - 50",
      AGE>50 ~ ">50",
      TRUE ~ NA_character_
  ),AGEGR9N = case_when(
    AGE<18 ~ 1,
    AGE>=18 & AGE<=50 ~ 2,
    AGE>50 ~ 3,
    TRUE ~ NA_real_
  ),
  ITTFL = if_else(!is.na(ARM),"Y","N")
  )

#Deriving variables from EX data set. First getting EXSTDTM and EXSTTMF
expo1 <- ex %>%
  derive_vars_dtm(
    dtc = EXSTDTC,
    new_vars_prefix = "EXST",
    time_imputation = "first"
  )

# Now adding the obtained EX variables to ADSL and applying our filter
adsl <- adsl %>% 
  derive_vars_merged(
    dataset_add = expo1,
    filter_add=(EXDOSE>0 | (EXDOSE==0 & str_detect(EXTRT,"PLACEBO"))) &
                 !is.na(EXSTDTM),
               new_vars = exprs(TRTSDTM = EXSTDTM, TRTSTMF = EXSTTMF),
               order = exprs(EXSTDTM, EXSEQ),
                mode = "first",
              by_vars = exprs(STUDYID,USUBJID)
  )

# Since we need max date out of dates from all the given SDTM data we will be using VS,AE,DS and ADSL      
  
#Deriving the variable from the VS data set
vspo <- vs %>%
  derive_vars_dt(
    dtc = VSDTC,
    new_vars_prefix = "VS"
  )

# Deriving the variable from the AE data set

aepo <- ae %>%
  derive_vars_dt(
    dtc = AESTDTC,
    new_vars_prefix = "AEST"
  )

# Deriving the variable from the DS data set

dspo <- ds %>%
  derive_vars_dt(
    dtc = DSSTDTC,
    new_vars_prefix = "DSST"
  )

#Deriving the end date variable from EX data set similar to how we did for start date

expo2 <- ex %>%
  derive_vars_dtm(
    dtc = EXENDTC,
    new_vars_prefix = "EXEN",
    time_imputation = "last"
  )


# Now adding the obtained variables one by one to ADSL and applying our filters
adsl <- adsl %>% 
  derive_vars_merged(
    dataset_add = expo2,
    filter_add=(EXDOSE>0 | (EXDOSE==0 & str_detect(EXTRT,"PLACEBO"))) &
      !is.na(EXENDTM),
    new_vars = exprs(TRTEDTM = EXENDTM),
    order = exprs(EXENDTM, EXSEQ),
    mode = "last",
    by_vars = exprs(STUDYID,USUBJID)
  )

#Finally we create a data set from all the dates we have derived and then take max out of them

alive_dates <- bind_rows(
  vspo %>% 
    filter(!is.na(VSDT),!(is.na(VSSTRESN) & is.na(VSSTRESC))) %>%
    transmute(STUDYID,USUBJID,ALVDT=VSDT),
  aepo %>%
    filter(!is.na(AESTDT)) %>%
    transmute(STUDYID,USUBJID,ALVDT=AESTDT),
  dspo %>%
    filter(!is.na(DSSTDT)) %>%
    transmute(STUDYID,USUBJID,ALVDT=DSSTDT),
  adsl %>%
    filter(!is.na(TRTEDTM)) %>%
    transmute(STUDYID,USUBJID,ALVDT=as.Date(TRTEDTM))
)

last_alive <- alive_dates %>%
  group_by(STUDYID, USUBJID) %>%
  summarise(LSTAVLDT = max(ALVDT, na.rm = TRUE), .groups = "drop")

adsl <- adsl %>%
  left_join(last_alive, by = c("STUDYID", "USUBJID"))
  
# Saving the output

write.csv(
  adsl,
  "question_2_adam/adsl.csv",
  row.names = FALSE
)

cat("Question 2 adsl creation completed successfully.\n")
cat("Number of records in adsl dataset:", nrow(adsl), "\n")
cat("Variables in final adsl dataset:\n")
print(names(adsl))
cat("Preview of final adsl dataset:\n")
print(head(adsl))

#creating log
sink()
