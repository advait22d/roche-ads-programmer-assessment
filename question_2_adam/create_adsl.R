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
      AGE>=18 & AGE<=50 ~ "18-50",
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
expo <- ex %>%
  derive_vars_dtm(
    dtc = EXSTDTC,
    new_vars_prefix = "EXST",
    time_imputation = "first"
  )

# Now adding the obtained EX variables to ADSL and applying our filter
adsl <- adsl %>% 
  derive_vars_merged(
    dataset_add = expo,
    filter_add=(EXDOSE>0 | (EXDOSE==0 & str_detect(EXTRT,"PLACEBO"))) &
                 !is.na(EXSTDTM),
               new_vars = exprs(TRTSDTM = EXSTDTM, TRTSTMF = EXSTTMF),
               order = exprs(EXSTDTM, EXSEQ),
                mode = "first",
              by_vars = exprs(STUDYID,USUBJID)
  )
      
  





