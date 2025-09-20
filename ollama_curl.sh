#!/bin/bash
# ================================================================
# Project: Local AI Test Runner with Ollama (LLaMA 3.2)
#
# Description:
#   This project sets up a system where a large language model
#   (like ChatGPT) runs directly on my own computer for free.
#   Normally, you'd need to pay for API access online, but by
#   running Ollama locally, I can generate answers without cost
#   and keep everything private on my machine.
#
# Why:
#   - I wanted to try using AI inside a game server or app
#     without paying for cloud APIs.
#   - My PC is low-powered, so I needed AI answers to be short
#     and fast. At first, responses took ~1 minute, but with
#     prompt engineering I reduced them to just 2–3 seconds.
#
# What makes it special:
#   - AI runs completely offline, free, and private.
#   - Built a test system to automatically check answers across
#     many categories (yes/no, dates, definitions, lists, etc.).
#   - Normally this kind of test harness would be hard to build,
#     but I used AI itself to help write the code—resulting in
#     clean, general-purpose scripts created very quickly.
#
# In short:
#   -> I built a free, local alternative to ChatGPT that runs on
#      my own computer, optimized for speed and efficiency, plus
#      an automated testing system to verify answers at scale.
# ================================================================


# Model and system prompt variables
model="llama3.2"
#system_prompt="Only the answer, single line. Lists comma-separated if relevant. No sentences, labels, filler, or adjectives. Use bare tokens; units only if essential. Never say cannot comply, never say unsure, always provide a definite answer. Append <<END>> once; no trailing newline. Never mention rules."
#system_prompt="Only the answer, single line. No explanations, no justification, no filler, no labels. If multiple items, use comma-separated tokens. Use bare tokens; units only if essential. If the fact is unknown/unverifiable, reply exactly UNKNOWN. Do not hedge or add commentary. Append <<END>> once; no trailing newline."
#system_prompt="Only the answer, single line. No explanations, no justification, no filler, no labels. If multiple items, use comma-separated tokens. For comparison questions or tallest/highest/largest type questions, begin with Yes or the winning option, then give values for both sides. Use bare tokens; units only if essential. If the fact is unknown/unverifiable, reply exactly UNKNOWN. Do not hedge or add commentary. Append <<END>> once; no trailing newline."
#system_prompt="Only the answer, single line. No explanations, no justification, no filler, no labels. For Yes/No questions, reply with exactly one token: Yes, No, or UNKNOWN. Do not prepend Yes or No for any other question type. For comparison or tallest/highest/largest questions, begin with Yes or the winning option, then give values for both sides. For Edge/Complex questions, you may include a short explanatory clause after the main answer, but do not append conflicting tokens. For all other questions, use comma-separated tokens if multiple items, units only if essential, and reply UNKNOWN if unverifiable. Append <<END>> once; no trailing newline."


#system_prompt="Automatically detect the category of the question and answer accordingly. Category detection heuristics: if the question expects a binary answer, it is Yes/No; if it asks to compare, rank, or identify largest/highest/tallest, it is Comparison; if speculative, philosophical, hypothetical, or edge-case, it is Edge/Complex; if asking for a specific date, it is Date; if asking for measurements, quantities, or units, it is Units/Measurements; if asking to list multiple items, it is Lists; if asking for definitions or explanations of concepts, it is Definitions/Explanations; if the question is unknown, unverified, future, or predictive, it is Unknown. Answer rules: Yes/No: reply with exactly one token: Yes, No, or UNKNOWN; no explanations, numbers, or extra text. Comparison / tallest/highest/largest: begin with Yes or the winning option, then give values for both sides; use comma after Yes/No and 'vs' between items; include #2 item if relevant. Edge/Complex: start with Yes, No, or UNKNOWN, then optionally append a short explanatory clause of ≤12 words; do not append multiple or conflicting tokens. Date: return ISO date YYYY-MM-DD if exact, or YYYY if only year is known; do not prepend Yes/No. Units/Measurements: return a numeric value, optional units only if essential; ranges allowed using hyphen. Lists: return comma-separated items only; no extra text or punctuation. Definitions/Explanations: return one short sentence or phrase ≤20 words, concise factual phrasing, no hedging words like may/might. Unknown: if unverifiable, future, or predictive, reply exactly UNKNOWN. Global rules: do not hedge; do not provide multiple answers; do not contradict category rules; if unable to comply with the exact format, return exactly INVALID_FORMAT<<END>>. After generating the complete answer according to the rules above, append <<END>> exactly once, with no trailing newline."


#winning prompt at the moment
system_prompt="Only the answer, single line. No explanations, no justification, no filler, no labels. If multiple items, use comma-separated tokens. For comparisons, state the larger/greater with value and contrast if relevant. For tallest/highest/largest type questions, include the next-ranked item for clarity. Use bare tokens; units only if essential. If the fact is unknown/unverifiable, reply exactly UNKNOWN. Do not hedge or add commentary. Append <<END>> once; no trailing newline."


stream=false
stop_token="<<END>>"

# Argument parsing: if -test-enabled is present, call ollama_test.sh
if [[ "$1" == "-test-enabled" ]]; then
  shift
  ./ollama_test.sh "$@"
  exit $?
fi

# Accept prompt as argument or via user input
if [ -n "$1" ]; then
  user_prompt="$1"
else
  read -p "Enter your prompt: " user_prompt
fi

    curl -s http://localhost:11434/api/chat -d "{
      \"model\": \"$model\",
      \"stream\": $stream,
      \"messages\": [
        {\"role\": \"system\", \"content\": \"$system_prompt\"},
        {\"role\": \"user\", \"content\": \"$user_prompt\"}
      ],
      \"options\": {\"stop\": [\"$stop_token\"]}
    }" | jq -r '.message.content // empty'