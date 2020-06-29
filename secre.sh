#!/bin/sh

for FILE in $(git diff-index HEAD --name-only | grep /Users/israodin/Documents/study/israodin_platform/kubernetes-templating/frontend | grep "secrets.y"); do
    if [ -f "$FILE" ] && ! grep -C10000 "sops:" $FILE | grep -q "version:"; then
        echo "!!!!! $FILE" 'File is not encrypted !!!!!'
        echo "Run: helm secrets enc /Users/israodin/Documents/study/israodin_platform/kubernetes-templating/frontend/templates/secret.yaml"
        exit 1
    fi
done
exit
