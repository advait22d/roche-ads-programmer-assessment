#Defining the log 
sink("question_1_sdtm/q1_log.txt", split = TRUE)

#Importing the required libraries
library(sdtm.oak)
library(pharmaverseraw)
library(pharmaversesdtm)
library(tidyverse)

#Reading in the raw data
ds_raw <- pharmaverseraw::ds_raw
dm <- pharmaversesdtm::dm

#Creating oak_id_vars for further mapping
ds_raw <- ds_raw %>%
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "ds_raw"
  )

#Reading in the controlled terminology used for the study

study_ct <- read.csv("question_1_sdtm/metadata/sdtm_ct.csv")
#Mapping the topic variable first. In this case it is IT.DSTERM to DSTERM

ds <- assign_no_ct(
  raw_dat = condition_add(ds_raw,is.na(OTHERSP)),
  raw_var = "IT.DSTERM",
  tgt_var = "DSTERM",
  id_vars = oak_id_vars()
)



#Mapping the remaining variables

ds <- ds %>%
  assign_datetime(
    raw_dat = ds_raw,
    raw_var = "IT.DSSTDAT",
    tgt_var = "DSSTDTC",
    raw_fmt = c("m-d-y"),
    id_vars = oak_id_vars()
  ) %>%
  assign_ct(
    raw_dat = condition_add(ds_raw,is.na(OTHERSP)),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSDECOD",
    ct_spec = study_ct,
    ct_clst = "C66727",
    id_vars = oak_id_vars()
  )%>%
  hardcode_ct(
    raw_dat = condition_add(ds_raw,`IT.DSDECOD` == "Randomized"),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSCAT",
    tgt_val = "PROTOCOL MILESTONE",
    ct_spec = study_ct,
    ct_clst = "C74558",
    id_vars = oak_id_vars()
  ) %>%
  hardcode_ct(
      raw_dat = condition_add(ds_raw,`IT.DSDECOD` != "Randomized"),
      raw_var = "IT.DSDECOD",
      tgt_var = "DSCAT",
      tgt_val = "DISPOSITION EVENT",
      ct_spec = study_ct,
      ct_clst = "C74558",
      id_vars = oak_id_vars()
  ) %>%
  assign_no_ct(
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSDECOD",
    id_vars = oak_id_vars()
  ) %>%
  assign_no_ct(
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSTERM",
    id_vars = oak_id_vars()
  ) %>%
  hardcode_ct(
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSCAT",
    tgt_val = "OTHER EVENT",
    ct_spec = study_ct,
    ct_clst = "C74558",
    id_vars = oak_id_vars()
  ) %>%
  assign_datetime(
    raw_dat = ds_raw,
    raw_var = c("DSDTCOL","DSTMCOL"),
    tgt_var = "DSDTC",
    raw_fmt = c("m-d-y","H:M"),
    raw_unk = c("UN", "UNK"),
    id_vars = oak_id_vars()
  ) %>%
  assign_ct(
    raw_dat = ds_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISIT",
    ct_spec = study_ct,
    ct_clst = "VISIT",
    id_vars = oak_id_vars()
  ) %>%
  assign_ct(
    raw_dat = ds_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISITNUM",
    ct_spec = study_ct,
    ct_clst = "VISITNUM",
    id_vars = oak_id_vars()
  )

#Creating the Derived variables for the final SDTM data

ds <- ds %>%
  dplyr::mutate(
    STUDYID = ds_raw$STUDY,
    DOMAIN = "DS",
    USUBJID = paste0("01-",ds_raw$PATNUM),
    DSTERM = toupper(DSTERM)
  )%>%
  derive_seq(
    tgt_var = "DSSEQ",
    rec_vars = c("USUBJID","DSTERM")
  )%>%
  derive_study_day(
    sdtm_in = .,
    dm_domain = dm,
    tgdt = "DSSTDTC",
    refdt = "RFXSTDTC",
    study_day_var = "DSSTDY"
  ) %>%
  #Ordering and keeping necessary columns 
  select(
    STUDYID, DOMAIN, USUBJID, DSSEQ, DSTERM, DSDECOD, DSCAT,
    VISITNUM, VISIT, DSDTC, DSSTDTC, DSSTDY
  )

# Saving the output

write.csv(
  ds,
  "question_1_sdtm/ds.csv",
  row.names = FALSE
)

cat("Question 1 DS domain creation completed successfully.\n")
cat("Number of records in DS dataset:", nrow(ds), "\n")
cat("Variables in final DS dataset:\n")
print(names(ds))
cat("Preview of final DS dataset:\n")
print(head(ds))

#creating log
sink()
