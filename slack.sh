text=$*

escapedText=$(echo $text | sed 's/"/\"/g' | sed "s/'/\'/g" )
json="{\"text\": \"$escapedText\"}"

curl -s -d "payload=$json" "https://hooks.slack.com/services/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"