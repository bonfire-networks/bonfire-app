#!/bin/bash 
DIR="${1:-$PWD}" 

echo Checking for changes in $DIR

cd $DIR

git config core.fileMode false

# add all changes (including untracked files)
git add --all .

set +e  # Grep succeeds with nonzero exit codes to show results.

if git status | grep -q -E 'Changes|modified|ahead'
then
    set -e

    # if there are changes, commit them (needed before being able to rebase)
    git diff-index --quiet HEAD || git commit --verbose --all || echo Skipped...

    # fetch and rebase remote changes, or fallback to regular pulling if we skipped commiting
    git pull --rebase || git pull

    echo Publishing changes! 
    
    git push

else
    set -e
    #echo No local changes since last run 
    if [[ $2 == 'pull' ]]
    then
        git pull
    fi
fi
