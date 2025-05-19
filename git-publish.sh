#!/bin/bash 
DIR="${1:-$PWD}" 

function maybe_rebase {
    if [[ $1 == 'pull' ]]; then
        git pull --rebase || fail "Please resolve conflicts before continuing." 
    fi

    if [[ $1 == 'rebase' ]]; then
        # if rebasing we assume that jungle already fetched, so we try to directly rebase
        git rebase || fail "Please resolve conflicts before continuing." 
    fi
}

function commit {
    if [[ $1 == 'pr' ]]; then
        echo "Here are the changes you made:"
        git diff HEAD
        branch_and_commit "$2"
    else
        if [[ -n "$2" ]]; then
            echo "Comment for the commit: $2"
            git commit --all -m "$2"
        else
            echo "Enter a comment for the commit:"
            git commit --verbose --all
        fi
    fi
}

function branch_and_commit {
    provided_comment="$1"
    
    if [[ -n "$provided_comment" ]]; then
        comment="$provided_comment"
    else
        read -p "Enter a description of these changes for the commit and related PR (leave empty to skip these changes for now) and press enter:" comment
    fi
    
    if [[ -n "$comment" ]]; then
        name=${comment// /_}
        sanitized_name=${name//[^a-zA-Z0-9\-_]/}
        (git checkout -b "PR-${sanitized_name}" || branch_and_commit "$comment") && git commit --all -m "$comment" && gh pr create --fill 
    else
        fail "No comment entered, skipping these changes..."
    fi
}

function post_commit {
    # merge/rebase local changes
    maybe_rebase $1

    if [[ $2 != 'only' ]]; then
        git push && echo "Published changes!" 
    fi
}

function fail {
    printf '%s\n' "$1" >&2 ## Send message to stderr.
    exit "${2-1}" ## Return a code specified by $2, or 1 by default.
}


echo "Checking ($2) for changes in $DIR"

cd $DIR

git config core.fileMode false


set +e  # Grep succeeds with nonzero exit codes to show results.

if [ -z "$(git status --porcelain)" ]; then
    # there are no changes

    set -e
    echo "No local changes to push"

    maybe_rebase $2

else
    # there are changes
    set -e

    # add all changes (including untracked files)
    git add --all .

    # if there are changes, commit them (needed before being able to rebase)
    (commit "$3" "$4" && post_commit "$2" "$3") || echo "Skipped..."

fi
