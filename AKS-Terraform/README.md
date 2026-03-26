# AKS Terraform Workflow

This folder contains the Terraform code and Azure DevOps YAML pipelines used to provision and destroy AKS environments.

## Folder overview

- `Terraform-manifests/`: Terraform configuration for AKS, networking, monitoring, and node pools.
- `Terraform-provision-aks-cluster-pipeline.yml`: CI/CD pipeline that validates Terraform and provisions AKS environments.
- `Terraform-destroy-aks-cluster-pipeline.yml`: manual destroy pipeline with a required approval gate and a 2-hour timeout.
- `kube-manifests/`: Kubernetes manifests that can be deployed after the cluster is available.
- `aks-prod-sshkeys-terraform/`: local SSH key material used outside Azure DevOps. The pipeline uses the secure file instead.

## Provision workflow

1. A change to `main` triggers `Terraform-provision-aks-cluster-pipeline.yml`.
2. The pipeline publishes the Terraform manifests as a pipeline artifact.
3. Terraform is initialized and validated.
4. Separate deployment stages provision the `dev` and `qa` AKS environments.
5. Each environment uses its own Terraform remote state file:
   `aks-dev.tfstate` and `aks-qa.tfstate`.

## Destroy workflow

The destroy pipeline is intentionally separated from the provision pipeline and does not run automatically from Git pushes.

### What the destroy pipeline does

1. `trigger: none` and `pr: none` prevent automatic execution.
2. You manually choose the `targetEnvironment` parameter when starting the run.
3. The pipeline validates the Terraform configuration.
4. It creates a Terraform destroy plan for the selected environment only.
5. It publishes a destroy plan bundle artifact that contains:
   - the reviewed `.tfplan` file
   - a readable `.txt` summary from `terraform show`
6. The pipeline pauses for manual approval.
7. Approval must be given within 120 minutes.
8. If approval is not provided within 2 hours, the manual validation task rejects the run automatically.
9. If approved, the pipeline applies the exact reviewed destroy plan.

### Why this is safer

- The pipeline destroys only one environment at a time.
- The approval happens after the destroy plan is generated, so approvers can review what will be deleted.
- The same approved plan file is used for the destroy step, which avoids plan drift between approval and execution.
- The run expires automatically if no one responds in time.

## Azure DevOps setup steps

### 1. Create the destroy pipeline

1. In Azure DevOps, open `Pipelines`.
2. Select `New pipeline`.
3. Choose your repository.
4. Choose `Existing Azure Pipelines YAML file`.
5. Select `AKS-Terraform/Terraform-destroy-aks-cluster-pipeline.yml`.
6. Save the pipeline with a clear name such as `AKS Terraform Destroy`.

### 2. Add the secure file

1. Go to `Pipelines` -> `Library` -> `Secure files`.
2. Upload the SSH public key file if it is not already present.
3. Make sure the secure file name matches:
   `aks-terraform-devops-ssh-key-ubuntu.pub`
4. Authorize the destroy pipeline to use that secure file.

### 3. Verify the service connection

1. Go to `Project settings` -> `Service connections`.
2. Open `terraform-aks-azurerm-svc-con`.
3. Confirm the connection can access:
   - the Terraform state resource group
   - the storage account `strgterraformvp`
   - the AKS resource group(s) and dependent Azure resources
4. Grant the destroy pipeline permission to use the service connection.

### 4. Configure approval users

The pipeline uses two variables:

- `DESTROY_NOTIFY_USERS`: comma-separated email addresses that receive the approval notification
- `DESTROY_APPROVERS`: comma-separated users, groups, or teams allowed to approve

Set them in Azure DevOps:

1. Open the destroy pipeline.
2. Select `Edit`.
3. Open `Variables`.
4. Add `DESTROY_NOTIFY_USERS`.
5. Add `DESTROY_APPROVERS`.
6. Save the pipeline.

Example values:

- `DESTROY_NOTIFY_USERS = ops-team@contoso.com,platform-team@contoso.com`
- `DESTROY_APPROVERS = Contoso Project\\AKS Admins`

Notes:

- If `DESTROY_APPROVERS` is left blank, users with permission to queue builds can approve.
- Make sure approvers also have permission to view and act on pipeline runs.

### 5. Run the destroy pipeline

1. Open the destroy pipeline.
2. Select `Run pipeline`.
3. Choose `targetEnvironment`:
   - `dev`
   - `qa`
4. Start the run.
5. Wait for the `Create Destroy Plan` stage to finish.
6. Open the published artifact `${targetEnvironment}-destroy-plan` and review the text summary.
7. Approve or reject the manual validation step.

### 6. Understand the timeout behavior

- The manual approval job waits up to 120 minutes.
- If approved inside that window, the destroy stage starts.
- If rejected, the run stops and nothing is deleted.
- If no one responds within 2 hours, the task times out and rejects automatically.

## Optional environment-based approvals

The destroy stage writes deployment history to:

- `aks-destroy-dev`
- `aks-destroy-qa`

If you want to manage approvals centrally through Azure DevOps Environments instead of the YAML manual validation step:

1. Go to `Pipelines` -> `Environments`.
2. Create `aks-destroy-dev` and `aks-destroy-qa`.
3. Open each environment and select `Approvals and checks`.
4. Add an `Approval` check.
5. Set the approvers.
6. Set the timeout to 120 minutes.

Important:

- Keep the YAML `ManualValidation` step if you want the approval enforced by code.
- Remove the YAML approval stage only if you intentionally want environment checks to be the single approval gate.
- If you use both, the destroy run will require two approvals.

## Recommended operating model

- Use the provision pipeline for regular infrastructure creation and updates.
- Use the destroy pipeline only for controlled teardown events.
- Keep destroy permissions limited to a small operations/admin group.
- Review the destroy plan artifact before every approval.
- Do not enable CI triggers on the destroy pipeline.
