#!/bin/bash

# Ensure script exits if a command fails
set -e

# Function to display usage
usage() {
    echo "Usage: $0 --token <token> --repoName <repoName>"
    exit 1
}

# Check if required commands are installed
command -v git >/dev/null 2>&1 || { echo "Error: git is not installed. Please install git."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "Error: curl is not installed. Please install curl."; exit 1; }

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --token)
            token="$2"
            shift 2
            ;;
        --repoName)
            repoName="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

# Check mandatory parameters
if [ -z "$token" ] || [ -z "$repoName" ]; then
    usage
fi

# Get the commit message
commitMessage=$(git show -s --format=%s "$GIT_HASH")
echo "message: $commitMessage"

# Split the commit message by "#"
IFS='#' read -r -a messageArray <<< "$commitMessage"

# Initialize the shouldIncrement variable
shouldIncrement="no"

# Check if the messageArray has exactly 2 elements
if [ ${#messageArray[@]} -eq 2 ]; then
    prNumber=$(echo "${messageArray[1]}" | sed 's/)$//')
    echo "prNumber: $prNumber"

    # Check if prNumber is numeric
    if [[ "$prNumber" =~ ^[0-9.]+$ ]]; then
        echo "isPrNumberNumeric: true"

        # Get PR details from GitHub API
        prDetails=$(curl -s -H "Authorization: Bearer $token" "https://api.github.com/repos/$repoName/pulls/$prNumber")
        
        # Extract branch name using grep and awk
        branch=$(echo "$prDetails" | grep '"ref":' | awk -F'"ref":' '{print $2}' | awk -F'"' '{print $2}')
        echo "branch: $branch"

        # Check if EventName is "push" and set shouldIncrement
        if [ "$EVENT_NAME" = "push" ]; then
            echo "PR_BRANCH=$branch" >> "$GITHUB_OUTPUT"
            shouldIncrement="yes"
        fi
    else
        echo "isPrNumberNumeric: false"
    fi
fi

# Output the AutoIncrement value
echo "AutoIncrement=$shouldIncrement" >> "$GITHUB_OUTPUT"
