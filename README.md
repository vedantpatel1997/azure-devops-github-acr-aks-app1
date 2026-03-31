# AKS Learning Repo

This repo now contains two parallel infrastructure learning paths for the same AKS platform:

- `AKS-Terraform/`
- `AKS-Bicep/`

The goal is to help you compare how the same AKS environment feels in:

- Terraform with state, plan, and apply
- Bicep with what-if, deployment, and explicit delete workflows

## Start here

If you are learning both side by side, use this order:

1. Read [`AKS-Terraform/README.md`](AKS-Terraform/README.md).
2. Read [`AKS-Bicep/README.md`](AKS-Bicep/README.md).
3. Compare the infrastructure files in:
   - `AKS-Terraform/Terraform-manifests/`
   - `AKS-Bicep/Bicep-manifests/`
4. Run the Terraform pipeline first if you already know it.
5. Run the Bicep pipeline next and compare the review artifacts and deployment flow.

## Folder map

- `AKS-Terraform/`
  Terraform-based AKS infrastructure, provision pipeline, destroy pipeline, and Kubernetes sample manifests.
- `AKS-Bicep/`
  Bicep-based AKS infrastructure, create pipeline, destroy pipeline, parameter files, and helper script.
- `kube-manifests/`
  Simple Kubernetes deployment samples for AKS testing.
- `manifests/`
  Additional Kubernetes app manifests.
- root pipeline YAML files
  App build and deploy examples for ACR and AKS.

## Terraform vs Bicep at a glance

| Topic | Terraform in this repo | Bicep in this repo |
| --- | --- | --- |
| Infra folder | `AKS-Terraform/Terraform-manifests/` | `AKS-Bicep/Bicep-manifests/` |
| Review step | `terraform plan` | `az deployment sub what-if` |
| Apply step | `terraform apply <plan>` | `az deployment sub create` |
| State | Remote `.tfstate` in storage account | No separate state backend to manage |
| Destroy | `terraform plan -destroy` and `terraform apply` | Explicit delete workflow for resource group plus Microsoft Entra group cleanup |
| Approval model | Azure DevOps environments `dev`, `qa`, `prod` | Same Azure DevOps environments `dev`, `qa`, `prod` |
| SSH key handling | Secure file downloaded in pipeline | Same secure file reused in pipeline |

## Important learning takeaway

The Azure resources created by both approaches are intentionally very similar:

- resource group
- Log Analytics workspace
- virtual network and subnets
- AKS cluster
- Microsoft Entra AKS admin group
- optional Linux and Windows user node pools

The biggest practical difference is lifecycle handling:

- Terraform keeps state and knows how to plan creation, change, and destruction from that state.
- Bicep focuses on desired-state deployment. Create and update are natural. Destroy is something you design explicitly.

That difference is why the Bicep destroy pipeline is intentionally written as a teaching example instead of trying to pretend Bicep has a Terraform-style destroy command.
