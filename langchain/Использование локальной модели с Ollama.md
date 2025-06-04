```python
from langchain_ollama import OllamaLLM  
  
  
llm = OllamaLLM(model="qwen3:14b", base_url="http://192.168.0.106:11434")  
  
for chunk in llm.stream("The first man on the moon was ..."):  
    print(chunk, flush=True, end="")
```

