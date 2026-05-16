#Using the agent class we created in our main script to test out a few examples
from clinical_trial_data_agent import clinical_agent, df, schema_definition

agent = clinical_agent(df, schema_definition)

test_questions = [
    "Give me the subjects who had adverse events of Moderate severity.",
    "Show me subjects who had Headache.",
    "Give me subjects with Cardiac disorders."
]

for question in test_questions:
    agent.ask(question)
