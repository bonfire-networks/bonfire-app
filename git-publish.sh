#!/bin/bash 
DIR="${1:-$PWD}" 

echo Checking for changes in $DIR

cd $DIR

git add .

set +e  # Grep succeeds with nonzero exit codes to show results.

if git status | grep -q -E 'modified|ahead'
then
    set -e

    git config core.fileMode false

    # have to add/commit before being able to rebase
    git commit -a

    # fetch and rebase remote changes
    git pull --rebase

    echo Publishing changes! 
    git push

else
    set -e
    #echo No local changes since last run 
    git pull
fi
