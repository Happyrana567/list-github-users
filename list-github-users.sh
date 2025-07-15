#!/bin/bash

# GitHub API base URL
API_URL="https://api.github.com"

# Prompt for GitHub username if not set as env variable
if [[ -z "$GITHUB_USERNAME" ]]; then
  read -p "Enter your GitHub username: " GITHUB_USERNAME
fi

# Prompt for GitHub Personal Access Token without echoing to screen
if [[ -z "$GITHUB_TOKEN" ]]; then
  read -s -p "Enter your GitHub Personal Access Token: " GITHUB_TOKEN
  echo  # move to new line after input
fi

# Repository details
REPO_OWNER="devops-team-happy"
REPO_NAME="github-scripts-devops"

# Function to make a GET request to GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Use curl to make authenticated request
    curl -s -u "${GITHUB_USERNAME}:${GITHUB_TOKEN}" "$url"
}

# Function to list users with read access
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    # Fetch API response
    local response
    response=$(github_api_get "$endpoint")

    # Basic error handling: Check if response is an array (success)
    if ! echo "$response" | jq -e 'type == "array"' > /dev/null; then
        echo "❌ Failed to fetch collaborators. Response from GitHub:"
        echo "$response"
        return 1
    fi

    # Extract logins of collaborators with read (pull) access
    local collaborators
    collaborators=$(echo "$response" | jq -r '.[] | select(.permissions.pull == true) | .login')

    # Display the result
    if [[ -z "$collaborators" ]]; then
        echo "📭 No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "✅ Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

# -----------------------------
# Main Execution Starts Here
# -----------------------------
echo "🔍 Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access









