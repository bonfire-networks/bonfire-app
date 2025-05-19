#!/usr/bin/env bash

set -e

# Script to read .tool-versions library versions into environment variables
# in the form of <library_name>_version=<version_number>
# credit to https://github.com/smartcontractkit/tool-versions-to-env-action

# Create the functions

print_help() {
    echo "Requires at least 1 argument"
    echo "Argument #1: Action options"
    echo "  1 = print to .env file"
    echo "      Argument #2: Optional. The path to the .tool-versions file"
    echo "      Argument #3: Optional. The path to the .env file to create"
    echo "  2 = sent to github action output"
    echo "      Argument #2: Optional. The path to the .tool-versions file"
    echo "  3 = only print given variable to stdout"
    echo "      Argument #2: Required. The tool version to output to stdout"
    echo "      Argument #3: Optional. The path to the .tool-versions file"
    echo ""
    echo "Example for 1 or 2: tool-versions-to-env.sh 1"
    echo "Example for 3: tool-versions-to-env.sh 3 golang"
}

# First argument is a boolean of 0 = false or 1 = true to echo the variable.
# Second argument is the string to echo to std out.
to_echo() {
    if [ "$1" -eq 1 ]; then
        echo "$2"
    fi
}

# First argument is the output option,
#   1 to .env
#   2 to github action output
#   3 none
# Second arument is the .tool-versions location
# Third argument is the .env location
# Fourth argument is whether it is safe to echo to stdout
read_tool_versions_write_to_env() {
    local -r how_to_echo="$1"
    local -r tool_versions_file="$2"
    local -r env_file="$3"
    local -r safe_to_echo="$4"

    # clear the env file before writing to it later
    if [ "$how_to_echo" -eq 1 ]; then
        echo "" >"${env_file}"
    fi
    # loop over each line of the .tool-versions file
    while read -r line; do
        to_echo "$safe_to_echo" "Original line: $line"

        # split the line into a bash array using the default space delimeter
        IFS=" " read -r -a lineArray <<<"$line"

        # get the key and value from the array, set the key to all uppercase
        key="${lineArray[0],,}"
        value="${lineArray[1]}"

        # ignore comments, comments always start with #
        if [[ ${key:0:1} != "#" ]]; then
            full_key="${key}_version"
            to_echo "${safe_to_echo}" "Parsed line:   ${full_key}=${value}"
            # echo the variable to the .env file
            if [ "$how_to_echo" -eq 1 ]; then
                echo "${full_key^^}=${value}" >>"${env_file}"
            elif [ "$how_to_echo" -eq 2 ]; then
                echo "${full_key^^}=$value" >>"$GITHUB_ENV"
            elif [ "$how_to_echo" -eq 3 ]; then
                # echo "$value"
                # break
                echo " ${full_key^^}=${value}"
            fi
        fi
    done <"$tool_versions_file"
}

# Run the code

if [ $# -eq 0 ]; then
    print_help
    exit 1
fi

# Action option
ACTION_OPTION=${1}
# path to the .tool-versions file
TOOL_VERSIONS_FILE=${2:-"./.tool-versions"}
# path to the .env file
ENV_FILE=${3:-"./.env"}

if [ "$ACTION_OPTION" -eq 1 ]; then
    # print to .env
    read_tool_versions_write_to_env 1 "$TOOL_VERSIONS_FILE" "$ENV_FILE" 1
elif [ "$ACTION_OPTION" -eq 2 ]; then
    # print to github action
    read_tool_versions_write_to_env 2 "$TOOL_VERSIONS_FILE" "$ENV_FILE" 1
elif [ "$ACTION_OPTION" -eq 3 ]; then
    TOOL_VERSIONS_FILE=${3:-"./.tool-versions"}
    # print single to variable to stdout
    read_tool_versions_write_to_env 3 "$TOOL_VERSIONS_FILE" "" 0
else
    echo "First argument was not of option 1, 2, or 3"
fi