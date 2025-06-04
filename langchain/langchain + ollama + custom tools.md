```python
import os  
os.environ['OLLAMA_HOST'] = 'http://192.168.0.106:11434'  
  
from langchain_ollama import OllamaLLM  
from langchain.agents import initialize_agent, Tool  
from langchain.agents.agent_types import AgentType  
  
llm = OllamaLLM(model="qwen3:14b", base_url="http://192.168.0.106:11434")  
  
  
def weather_api(city):  
    return f"The weather in {city} is sunny."  
  
tools = [  
    Tool(  
        name="Get Weather",  
        func=weather_api,  
        description="Get the weather for a given city."  
    ),  
    Tool(  
        name="Calculator",  
        func=lambda x: str(eval(x)),  
        description="Evaluates a math expression."  
    )  
]  
  
agent = initialize_agent(tools, llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION)  
result = agent.invoke({"input": "What is 25245 * 21189?"})  
print(result)
```