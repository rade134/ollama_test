#!/bin/bash
# ollama_curl.sh
read -p "Enter your prompt: " user_prompt

curl -s http://localhost:11434/api/generate -d "{
  \"model\": \"llama3.2\",
  \"prompt\": \"$user_prompt\",
  \"stream\": false
}"