#!/bin/bash
DIR="${1:-$PWD}"

function fail {
    printf '%s\n' "$1" >&2 ## Send message to stderr.
    exit "${2-1}" ## Return a code specified by $2, or 1 by default.
}

function show_diff {
    echo "Here are the changes you made in $DIR:"
    git --no-pager diff --color --stat HEAD
    git --no-pager diff --color HEAD
}

function show_diff_incoming {
    local before="$1"
    local after
    after=$(git rev-parse HEAD)

    if [[ "$before" != "$after" ]]; then
        echo "Here are the changes that came in for $DIR:"
        git --no-pager log --color --oneline "$before..$after"
        git --no-pager diff --color --stat "$before" "$after"
        git --no-pager diff --color "$before" "$after"
    fi
}

function rebase_in_progress {
    [[ -d "$(git rev-parse --git-path rebase-merge)" ]] || [[ -d "$(git rev-parse --git-path rebase-apply)" ]]
}

# Files with conflict markers, comma separated (empty when there are none)
function unmerged_paths {
    local paths
    paths=$(git diff --name-only --diff-filter=U 2>/dev/null)
    printf '%s' "${paths//$'\n'/, }"
}

# The dir is expected to be a clone of its own. `extensions/bonfire` and friends are plain directories, and git resolves them to the enclosing app repo, so committing there would publish the whole app under the guise of updating one extension.
function is_own_repo {
    local top
    top=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
    [[ "$top" == "$(pwd -P)" ]]
}

# Refuse to touch a repo that someone left mid-operation: `git add --all` followed by `git commit --all` would otherwise bake the conflict markers into a commit.
function check_nothing_in_progress {
    local what conflicts
    conflicts=$(unmerged_paths)

    if rebase_in_progress; then
        what="a rebase"
    elif [[ -f "$(git rev-parse --git-path MERGE_HEAD)" ]]; then
        what="a merge"
    elif [[ -f "$(git rev-parse --git-path CHERRY_PICK_HEAD)" ]]; then
        what="a cherry-pick"
    elif [[ -n "$conflicts" ]]; then
        what="an unresolved conflict"
    else
        return 0
    fi

    fail "$what is already in progress here${conflicts:+ (unresolved: $conflicts)}, so this repo was left untouched. Finish or abort it by hand, otherwise these changes get committed on top of conflict markers. Look with: cd $DIR && git status"
}

# Is there anything to rebase onto? Returns 1 (after saying why) when there isn't, which is a normal state for a local-only branch rather than a failure.
function has_upstream {
    local branch remote merge

    if ! git symbolic-ref -q HEAD > /dev/null; then
        echo "Nothing to rebase in $DIR: HEAD is detached, so there's no branch to rebase."
        return 1
    fi

    branch=$(git symbolic-ref --short HEAD)

    if git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' > /dev/null 2>&1; then
        return 0
    fi

    remote=$(git config --get "branch.$branch.remote")
    merge=$(git config --get "branch.$branch.merge")

    if [[ -n "$merge" ]]; then
        echo "Nothing to rebase in $DIR: branch '$branch' tracks ${remote:-?}/${merge#refs/heads/}, which no longer exists on the remote."
    else
        echo "Nothing to rebase in $DIR: branch '$branch' isn't tracking a remote branch."
    fi
    return 1
}

function maybe_rebase {
    local cmd="$1"
    local before out rc conflicts

    [[ "$cmd" == 'pull' || "$cmd" == 'rebase' ]] || return 0

    has_upstream || return 0

    before=$(git rev-parse HEAD)

    if [[ "$cmd" == 'pull' ]]; then
        out=$(git pull --rebase 2>&1) && rc=0 || rc=$?
    else
        # if rebasing we assume that jungle already fetched, so we try to directly rebase
        out=$(git rebase 2>&1) && rc=0 || rc=$?
    fi

    printf '%s\n' "$out"

    if [[ $rc -ne 0 ]]; then
        conflicts=$(unmerged_paths)

        if rebase_in_progress || [[ -n "$conflicts" ]]; then
            # Abort rather than leave it pending: you can't start a merge from inside a rebase, and merging is often the better way out, since a rebase replays every local commit and so brings the same conflict back once per commit.
            git rebase --abort > /dev/null 2>&1 || true
            fail "Rebase hit conflicts in ${conflicts:-unknown files}, and was aborted so the tree is clean. Pick one of:
  cd $DIR && git pull --rebase     # try the rebase again
  cd $DIR && git pull --no-rebase  # merge instead, so you resolve the conflict just once"
        else
            fail "Could not rebase: ${out//$'\n'/ }"
        fi
    fi

    show_diff_incoming "$before"
}

function commit {
    if [[ $1 == 'pr' ]]; then
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
        # not a failure: entering no comment is how you skip a repo
        echo "No comment entered, skipping these changes..."
        return 1
    fi
}

function post_commit {
    # merge/rebase local changes
    maybe_rebase "$1"

    if [[ $2 != 'only' ]]; then
        if git push; then
            echo "Published changes!"
        else
            fail "Could not push. The changes are committed locally, they just aren't published. Retry with: cd $DIR && git push"
        fi
    fi
}


echo "Checking ($2) for changes in $DIR"

cd $DIR

if ! is_own_repo; then
    echo "Skipping $DIR: it isn't a clone of its own, so anything committed here would act on the enclosing repo."
    exit 0
fi

git config core.fileMode false

check_nothing_in_progress


set +e  # Grep succeeds with nonzero exit codes to show results.

if [ -z "$(git status --porcelain)" ]; then
    # there are no changes

    set -e
    echo "No local changes to push"

    maybe_rebase "$2"

else
    # there are changes
    set -e

    # add all changes (including untracked files), so new files also show up in the diff
    git add --all .

    show_diff

    # only a declined commit counts as a skip: a failed rebase or push must not be swallowed, or the run reports success while leaving the clone behind
    if commit "$3" "$4"; then
        post_commit "$2" "$3"
    else
        echo "Skipped committing changes in $DIR"
    fi

fi
