#!/bin/bash

# Ensure script exits if a command fails
set -e

# Function to display usage
usage() {
    echo "Usage: $0 --token <token> --repoName <repoName> --commitMessage <commitMessage> --eventName <eventName>"
    exit 1
}

# Check if required commands are installed
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
        --eventName)
            eventName="$2"
            shift 2
            ;;            
        --commitMessage)
            commitMessage="$2"
            shift 2
            ;;            
        *)
            usage
            ;;
    esac
done

# Check mandatory parameters
if [ -z "$token" ] || [ -z "$repoName" ] || [ -z "$commitMessage" ] || [ -z "$eventName" ]; then
    usage
fi

# Split the commit message by "#"
IFS='#' read -r -a messageArray <<< "$commitMessage"

# Initialize the shouldIncrement variable
shouldIncrement="no"

# Check if the messageArray has exactly 2 elements
if [ ${#messageArray[@]} -eq 2 ]; then
    prNumber=$(echo "${messageArray[1]}" | sed 's/)$//')

    # Check if prNumber is numeric
    if [[ "$prNumber" =~ ^[0-9.]+$ ]]; then

        # Get PR details from GitHub API
        prDetails=$(curl -s -H "Authorization: Bearer $token" "https://api.github.com/repos/$repoName/pulls/$prNumber")
        
        # Extract branch name using grep and awk
        branch=$(echo "$prDetails" | grep '"ref":' | awk -F'"ref":' '{print $2}' | awk -F'"' '{print $2}')

        # Check if EventName is "push" and set shouldIncrement
        if [ "$eventName" = "push" ]; then
            echo "PR_BRANCH=$branch"
            shouldIncrement="yes"
        fi
    fi
fi

# Output the AutoIncrement value
echo "AutoIncrement=$shouldIncrement"
