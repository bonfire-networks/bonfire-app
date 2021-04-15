#!/bin/bash 
git pull --rebase
set +e  # Grep succeeds with nonzero exit codes to show results.
if git status | grep -q -E 'modified|ahead'
then
    set -e
    echo "Publishing changes in $(PWD)"
    git add .
    git commit -a
    git push
else
    set -e
    echo "No local changes since last run in $(PWD)"
fi
