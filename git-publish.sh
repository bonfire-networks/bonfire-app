#!/bin/bash 
DIR="${1:-$PWD}" 

function fail {
    printf '%s\n' "$1" >&2 ## Send message to stderr.
    exit "${2-1}" ## Return a code specified by $2, or 1 by default.
}

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

    # if [[ $2 == 'pull' ]] 
    # then
    #     git fetch
    # fi

    # merge/rebase local changes
    # git rebase origin
    git pull --rebase && echo "Publishing changes!" || fail "Please resolve conflicts before continuing." 

    if [[ $2 != 'pull' && $2 == 'maybe-pull' ]] 
    then
        git push
    fi

else
    set -e
    #echo No local changes since last run 

    if [[ $2 == 'pull' ]] 
    then
        git pull --rebase || fail "Please resolve conflicts before continuing." 
    fi

    if [[ $2 == 'maybe-pull' ]] 
    then
        # if jungle is available and we assume fetches were already done
        # command -v jungle || 
        git pull --rebase || fail "Please resolve conflicts before continuing." 
    fi
fi
