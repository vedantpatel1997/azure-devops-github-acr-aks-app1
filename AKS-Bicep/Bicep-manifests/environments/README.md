# Environment Parameter Files

This folder contains one small parameter file per environment:

- `dev.parameters.json`
- `qa.parameters.json`
- `prod.parameters.json`

Each file currently sets only one value:

- `environment`

That is intentional.

Shared cross-environment values now live in:

- `../shared.parameters.json`

That split keeps it easy to see:

- what changes per environment
- what stays shared across environments

## Why this is useful for learning

Terraform in this repo passes the environment name from the pipeline.

The Bicep example keeps the environment choice in a small parameter file so you can:

- run `what-if` locally without editing the template
- see how environment-specific inputs are separated from shared logic
- understand how Azure DevOps can point to a different parameter file for each environment

## When to expand these files

If you want different values per environment later, this is the right place to add them.

Good examples:

- different Kubernetes versions
- enabling Linux or Windows user node pools only in selected environments
- different VM sizes
- different tag sets
