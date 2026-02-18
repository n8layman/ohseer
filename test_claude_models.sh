#!/bin/bash
source .env

echo "Testing Claude model access..."
echo ""

# Test different model IDs
models=(
  "claude-opus-4.5"
  "claude-opus-4-6"
  "claude-sonnet-4.5"
  "claude-sonnet-4-5"
)

for model in "${models[@]}"; do
  echo "Testing: $model"
  curl -s https://api.anthropic.com/v1/messages \
    -H "content-type: application/json" \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -d "{
      \"model\": \"$model\",
      \"max_tokens\": 100,
      \"messages\": [{
        \"role\": \"user\",
        \"content\": \"Hello\"
      }]
    }" | head -5
  echo ""
  echo "---"
  echo ""
done
