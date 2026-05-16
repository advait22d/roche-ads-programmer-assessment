#Importing the required libraries
import pandas as pd
import json

# Loading ADAE dataset
df = pd.read_csv("ae.csv")
print("Dataset loaded successfully")
print(df.head())

#Defining a schema dictionary for the LLM

schema_definition = {
    "AESEV": {
        "description": "Severity or intensity of the adverse event",
        "values": sorted(df["AESEV"].dropna().unique().tolist())
    },
    "AETERM": {
        "description": "Reported adverse event term or condition",
        "values": sorted(df["AETERM"].dropna().unique().tolist())
    },
    "AESOC": {
        "description": "System organ class or body system affected",
        "values": sorted(df["AESOC"].dropna().unique().tolist())
    },
    "USUBJID": {
        "description": "Unique subject identifier"
    }
}

class clinical_agent:
#class constructor  
  def __init__(self,dataframe,schema):
    self.df = dataframe
    self.schema = schema

#finding matching values from the question asked    
  def find_matching_value(self,question,column):
    question_lower = question.lower()
    
    for value in self.schema[column]["values"]:
      value_lower = str(value).lower()
      
      if value_lower in question_lower:
        return value
    
    return None
  
#Depending on the output of the mathcer the parser returns the specific answer condition 
  def mock_llm_parse(self, question):
    sev_match = self.find_matching_value(question, "AESEV")
    term_match = self.find_matching_value(question, "AETERM")
    soc_match = self.find_matching_value(question, "AESOC")

    if sev_match:
      return {
        "target_column": "AESEV",
        "filter_value": sev_match
      }

    if term_match:
      return {
        "target_column": "AETERM",
        "filter_value": term_match
      }

    if soc_match:
      return {
        "target_column": "AESOC",
        "filter_value": soc_match
      }

    return {
      "target_column": None,
      "filter_value": None
    }

#Now that we have the target_column and filter_value we actually filter our main dataset using them
  def execute_query(self,parsed_output):
    target_column = parsed_output["target_column"]
    filter_value =  parsed_output["filter_value"]
    
    if target_column is None or filter_value is None:
        return {
            "message": "Could not map question to AESEV, AETERM, or AESOC.",
            "unique_subject_count": 0,
            "matching_subject_ids": []
        }
    
    filtered_df = self.df[
        self.df[target_column].astype(str).str.upper() == str(filter_value).upper()
    ]
    
    subject_ids = sorted(filtered_df["USUBJID"].dropna().unique().tolist())
    
    return {
        "target_column": target_column,
        "filter_value": filter_value,
        "unique_subject_count": len(subject_ids),
        "matching_subject_ids": subject_ids
    }

#Here we call the functions and get ready to ask our questions    
  def ask(self, question):
    parsed_output = self.mock_llm_parse(question)
    result = self.execute_query(parsed_output)

    print("\nQuestion:", question)
    print("Mock LLM JSON Output:")
    print(json.dumps(parsed_output, indent=2))
    print("Execution Result:")
    print(json.dumps(result, indent=2))

    return result
  


