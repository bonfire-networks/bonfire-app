#!/bin/bash 
DIR="${1:-$PWD}" 

echo Checking for changes in $DIR

cd $DIR

# add all changes (including untracked files)
git add --all .

set +e  # Grep succeeds with nonzero exit codes to show results.

if git status | grep -q -E 'Changes|modified|ahead'
then
    set -e

    git config core.fileMode false

    # if there are changes, commit them (needed before being able to rebase)
    git diff-index --quiet HEAD || git commit --verbose --all || echo Skipped...

    # fetch and rebase remote changes
    git pull --rebase

    echo Publishing changes! 
    
    git push

else
    set -e
    #echo No local changes since last run 
    if [ $2 == 'pull' ]
    then
        git pull
    fi
fi
