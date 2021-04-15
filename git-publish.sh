#!/bin/bash 
DIR="${1:-$PWD}" 

echo Checking for changes in $DIR

cd $DIR
git config core.fileMode false

# have to add/commit before being able to rebase
git add .
git commit -a

# fetch and rebase remote changes
git pull --rebase

set +e  # Grep succeeds with nonzero exit codes to show results.
if git status | grep -q -E 'modified|ahead'
then
    set -e
    echo Publishing changes 
    git push
else
    set -e
    echo No local changes since last run 
fi
