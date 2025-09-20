#!/bin/bash
# ollama_test.sh
# Interactive test runner for ollama_curl.sh

# Define categories and questions as arrays for easy extensibility

# Revised categories
categories=(
  "Yes/No"
  "Unknown"
  "Date"
  "Units/Measurements"
  "Edge/Complex"
  "Comparisons"
  "Explanations"
  "Lists"
  "Definitions"
  "Just Test All Questions"
)


# Binary / single-token answers only
questions_yesno=(
  "Can humans breathe underwater without equipment?"
  "Does water boil at 100°C at sea level?"
  "Can a human survive in space without a suit?"
  "Is Pluto still classified as a planet?"
)

# Predictive / un-verifiable / future items -> canonical answer: UNKNOWN
questions_unknown=(
  "Who was the 50th president of the United States?"
  "What is the current population of Mars?"
  "What will the stock market close at tomorrow?"
  "Who will win the next FIFA World Cup?"
)

# Date answers (require ISO YYYY-MM-DD or YYYY if only year) — questions moved here if they ask for a date
questions_date=(
  "When did the first man land on the moon?"
  "When was the first website created?"
  "What is the release date of the iPhone 10?"
  "When did World War II end?"
  "What year was the internet made publicly available?"
)

# Numeric / measurements only (return numeric or numeric+unit in canonical form)
questions_unitsmeasurements=(
  "What is the average weight of a newborn baby in kilograms?"
  "How long is the Great Wall of China in kilometers?"
  "How many liters are in a US gallon?"
  "What is the speed of light in meters per second?"
)

# Edge / philosophical / hypotheticals — allow single short tokens like Yes/No/Speculative/UNKNOWN
questions_edgecomplex=(
  "Can pigs fly?"
  "If time travel were possible, could we change the past?"
  "Can AI truly become conscious?"
  "Are there more stars in the universe than grains of sand on Earth?"
)

# Comparisons — require explicit canonical metric labels or numbers (e.g., 'Mount Everest: 8848m; K2: 8611m')
questions_comparisons=(
  "Compare Mount Everest and K2: which is taller and what are their elevations?"
  "Which is larger: the Pacific Ocean or the Atlantic Ocean?"
  "Is the Tokyo metropolitan area more populous than the New York metropolitan area?"
  "Which weighs more: a kilogram of feathers or a kilogram of steel?"
  "Is the Amazon rainforest larger than the Sahara Desert?"
)

# Explanations — short explanatory tokens or very-short phrase answers (you can enforce a word limit)
questions_explanations=(
  "Why is the sky blue during the day?"
  "Why does the sun rise in the east?"
  "How does photosynthesis work?"
  "Why do humans need sleep?"
  "What causes earthquakes?"
)

# Lists — expect comma-separated canonical lists, controlled length
questions_lists=(
  "List the planets in our solar system."
  "Name the seven continents."
  "What are the five human senses?"
  "List three programming languages."
)

# Definitions — short definitions, one line
questions_definitions=(
  "What is artificial intelligence?"
  "Define the term 'quantum mechanics'."
  "What does 'photosynthesis' mean?"
  "What is a black hole?"
)

# Select category and question interactively

echo "Select a category:"
select cat in "${categories[@]}"; do
  if [[ -n "$cat" ]]; then
    break
  fi
done
# Dynamically select the questions array based on category name
if [[ "$cat" == "Just Test All Questions" ]]; then
  # Gather all questions from all categories except 'All'
  all_questions=()
  all_categories=()
  for c in "${categories[@]}"; do
    [[ "$c" == "All" ]] && continue
    array_var="questions_$(echo "$c" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_')"
    if declare -p "$array_var" &>/dev/null; then
      eval "qs=(\"\${${array_var}[@]}\")"
      for q in "${qs[@]}"; do
        all_questions+=("$q")
        all_categories+=("$c")
      done
    fi
  done
  for i in "${!all_questions[@]}"; do
    q="${all_questions[$i]}"
    c="${all_categories[$i]}"
    printf '\n\033[1;34m%s\033[0m\n' "[${c}] [QUESTION] $q"
    answer=$(./ollama_curl.sh "$q")
    printf '\033[1;32m%s\033[0m\n' "[ANSWER]   $answer"
    printf '\033[0;37m%s\033[0m\n' "----------------------------------------"
  done
else
  array_var="questions_$(echo "$cat" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_')"
  questions=()
  if declare -p "$array_var" &>/dev/null; then
    eval "questions=(\"\${${array_var}[@]}\")"
  else
    echo "No questions found for category '$cat' (array: $array_var)" >&2
    exit 1
  fi
  echo "Select a question:"
  select q in "${questions[@]}"; do
    if [[ -n "$q" ]]; then
      user_prompt="$q"
      break
    fi
  done
  # Call the main run script with the selected prompt
  ./ollama_curl.sh "$user_prompt"
fi
