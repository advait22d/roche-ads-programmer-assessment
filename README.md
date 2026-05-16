# roche-ads-programmer-assessment

## Overview

This repository contains solutions for the Roche ADS Programmer Assessment covering:

- SDTM dataset creation
- ADaM dataset derivation
- TLG generation and visualization
- GenAI Clinical Data Assistant using Python

---

## Repository Structure

```text
roche-ads-programmer-assessment/
│
├── question_1_sdtm/
├── question_2_adam/
├── question_3_tlg/
├── question_4_python/
├── README.md

---

## Question 1 – SDTM Dataset Creation

### Objective

Created SDTM DS domain dataset using pharmaverse packages and metadata-driven derivations.

### Outputs

- `ds.csv`
- `q1_log.txt`

### Main Packages Used

- sdtm.oak
- pharmaversesdtm
- pharmaverseraw
- dplyr

---

## Question 2 – ADaM ADSL Dataset

### Objective

Derived ADSL dataset including:

- AGEGR9 / AGEGR9N
- ITTFL
- TRTSDTM / TRTEDTM
- LSTAVLDT

### Outputs

- `adsl.csv`
- `q2_log.txt`

### Main Packages Used

- admiral
- dplyr
- lubridate
- pharmaversesdtm

---

## Question 3 – TLGs and Visualizations

### Objective

Generated:

1. TEAE summary table using `gtsummary`
2. AE severity stacked bar chart
3. Top 10 adverse events plot with 95% Clopper-Pearson confidence intervals

### Outputs

- `ae_summary_table.html`
- `severity_dist.png`
- `top10_ae.png`
- `q3_graphs_log.txt`

### Main Packages Used

- ggplot2
- gtsummary
- dplyr

---

## Question 4 – GenAI Clinical Data Assistant

### Objective

Developed a Python-based mock LLM clinical assistant that:

- interprets natural language clinical questions
- dynamically maps user intent to SDTM AE variables
- generates structured JSON outputs
- executes pandas filtering queries
- returns unique subject counts and matching USUBJID values

### Implementation Highlights

- Dynamic schema-driven parsing
- Mock LLM parser
- Structured JSON outputs
- Dynamic matching against dataset values
- Pandas-based query execution

### Files

- `clinical_trial_data_agent.py`
- `test_script.py`
- `ae.csv`

### Example Queries

- "Give me the subjects who had adverse events of Moderate severity."
- "Show me subjects who had Headache."
- "Give me subjects with Cardiac disorders."

---

## How to Run

### R Scripts

Run scripts directly in Posit Cloud / RStudio.

### Python Scripts

```bash
cd question_4_python
python3 test_script.py
