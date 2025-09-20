#!/bin/bash
# ollama_curl_path.sh
# Script to query RuneScape walking path AI and extract JSON output

model="llama3.2"

system_prompt="Generate a walking path based on RuneScape tiles. Output JSON only. Each step must be a relative move: dx/dy (e.g., +1,+1 is diagonal up-right, +1,0 is right, 0,+1 is up). Optionally include 'step' and 'timestamp' for each move. Only output valid moves; no extra text, no explanation, no commentary. Output must be valid JSON. Append <<END>> after the JSON exactly once; no trailing newline."

stream=false
stop_token="<<END>>"

# Accept prompt as argument or via user input
if [ -n "$1" ]; then
  user_prompt="$1"
else
  read -p "Enter your walking path description: " user_prompt
fi

# Call Ollama API
response=$(curl -s http://localhost:11434/api/chat -d "{
  \"model\": \"$model\",
  \"stream\": $stream,
  \"messages\": [
    {\"role\": \"system\", \"content\": \"$system_prompt\"},
    {\"role\": \"user\", \"content\": \"$user_prompt\"}
  ],
  \"options\": {\"stop\": [\"$stop_token\"]}
}")

# Extract the JSON block from the AI output
json_output=$(echo "$response" | jq -r '.message.content // empty' | sed 's/<<END>>//g' | \
              grep -oP '\{(?:[^{}]|(?R))*\}')  # recursive regex for JSON

# Validate JSON
if echo "$json_output" | jq '.' >/dev/null 2>&1; then
  echo "$json_output"  # valid JSON
else
  echo "ERROR: No valid JSON found in AI output"
fi
