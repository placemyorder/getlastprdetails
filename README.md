# Get Last PR Details

A GitHub Action that retrieves details from the last merged pull request and determines whether version auto-increment should be enabled based on the event type.

## Description

This action parses the last commit message to extract the PR number, fetches the PR details from the GitHub API, and outputs the branch name along with an auto-increment flag. It's particularly useful for automated versioning workflows where you need to conditionally increment versions based on merge events.

## Features

- Extracts PR number from commit messages
- Fetches PR details via GitHub API
- Returns the source branch name of the merged PR
- Determines if auto-increment should be enabled based on event type
- Lightweight Node.js 20 implementation

## Inputs

### `token`
**Required** The GitHub token to authenticate API requests. Typically `${{ secrets.GITHUB_TOKEN }}`.

### `reponame`
**Required** The repository name in the format `owner/repo` (e.g., `octocat/Hello-World`).

### `commitMessage`
**Required** The commit message from the merged PR. This should contain the PR number in the format `message (#123)`.

### `eventName`
**Required** The GitHub event that triggered this action (e.g., `push`, `pull_request`).

## Outputs

### `PR_BRANCH`
The branch name of the source branch from the last merged PR.

### `AutoIncrement`
A string value (`yes` or `no`) indicating whether auto-increment should be enabled. Returns `yes` only when the event is a `push` and a valid PR number is found.

## Usage

### Basic Example

```yaml
name: Version Management
on:
  push:
    branches:
      - main

jobs:
  check-version:
    runs-on: ubuntu-latest
    steps:
      - name: Get Last PR Details
        id: pr-details
        uses: placemyorderorg/getlastprdetails@v1
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          reponame: ${{ github.repository }}
          commitMessage: ${{ github.event.head_commit.message }}
          eventName: ${{ github.event_name }}

      - name: Use PR Details
        run: |
          echo "PR Branch: ${{ steps.pr-details.outputs.PR_BRANCH }}"
          echo "Auto Increment: ${{ steps.pr-details.outputs.AutoIncrement }}"
```

### Conditional Version Increment

```yaml
name: Auto Version
on:
  push:
    branches:
      - main

jobs:
  version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Get Last PR Details
        id: pr-details
        uses: placemyorderorg/getlastprdetails@v1
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          reponame: ${{ github.repository }}
          commitMessage: ${{ github.event.head_commit.message }}
          eventName: ${{ github.event_name }}

      - name: Increment Version
        if: steps.pr-details.outputs.AutoIncrement == 'yes'
        run: |
          echo "Incrementing version from branch: ${{ steps.pr-details.outputs.PR_BRANCH }}"
          # Your version increment logic here
```

## How It Works

1. The action parses the commit message looking for a PR number in the format `(#123)`
2. If a valid PR number is found, it makes an API call to GitHub to fetch the PR details
3. It extracts the source branch name from the PR
4. If the event is a `push`, it sets `AutoIncrement` to `yes`, otherwise `no`
5. Both values are returned as outputs for use in subsequent steps

## Requirements

- Node.js 20 runtime (automatically provided by GitHub Actions)
- Valid GitHub token with repository read access
- Commit messages should contain PR numbers in the format `(#123)`

## License

This action is available under the MIT License. See the LICENSE file for more details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you encounter any issues or have questions, please [open an issue](../../issues) on GitHub.
