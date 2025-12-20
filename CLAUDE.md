# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GitHub Action that triggers Jenkins jobs via the Jenkins API. The action is a thin wrapper around the `drone-jenkins` binary.

## Architecture

- **Dockerfile**: Uses `ghcr.io/appleboy/drone-jenkins` as the base image (the actual Go binary that handles Jenkins API calls)
- **entrypoint.sh**: Simple shell script that executes `/bin/drone-jenkins`
- **action.yml**: Defines the GitHub Action inputs and configuration

The core logic lives in the [drone-jenkins](https://github.com/appleboy/drone-jenkins) repository, not in this repo. This action simply packages that binary for GitHub Actions usage.

## Key Files

- `action.yml` - GitHub Action definition with all input parameters
- `Dockerfile` - Container image definition
- `entrypoint.sh` - Container entrypoint script

## CI/CD

- **Trivy scan**: Runs on push/PR to master and daily; checks for vulnerabilities, secrets, and misconfigurations
- **GoReleaser**: Triggers on version tags (`v*.*.*`) to create releases

## Testing

No local tests exist in this repository. Testing is done by:

1. Building the Docker image locally: `docker build -t jenkins-action .`
2. Testing against an actual Jenkins instance using the GitHub Action workflow
