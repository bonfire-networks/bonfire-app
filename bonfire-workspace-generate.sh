#!/bin/bash

echo '{
    "settings": {},
    "folders": [
        {
            "path": "."
        }' >"bonfire.code-workspace"

for fork in forks/*; do echo ", 
        {
            \"path\": \"$fork\"
        }"; done >>"bonfire.code-workspace"

echo ']}' >>"bonfire.code-workspace"