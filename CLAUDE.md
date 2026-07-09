# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A small Terraform project that manages the personal Azure infrastructure for `bradfordwagner` (single resource group `bradfordwagner-infra` in `eastus2`). It is not a reusable module library — the root module and its three children are specific to this one account.

## Commands

There is no local task runner or Makefile in this repo; the actual `terraform init/plan/apply` execution is delegated to an external repo (`bradfordwagner/taskfiles`, `tasks/terraform.yml`) that CI checks out at runtime. For local iteration, standard Terraform commands apply:

```bash
terraform init -backend-config=backend.hcl
terraform fmt -recursive
terraform validate
terraform plan
```

`backend.hcl` holds the azurerm remote-state settings (subscription, storage account, container, state key) consumed via `-backend-config`.

## Architecture

- `providers.tf` — pins `azurerm` provider (`>=2.0`) and Terraform (`>=1.0.0`).
- `main.tf` — creates the single `azurerm_resource_group.rg` and wires up three child modules, each pointed at that resource group by name: `modules/k8s_cluster`, `modules/blob_storage`, `modules/keyvault`.
- Each child module loads the resource group as a `data "azurerm_resource_group"` source (rather than passing the object through), and every real resource is gated by `count = var.enabled ? 1 : 0`. Modules are toggled on/off from `main.tf` via the `enabled` argument — all three are currently `enabled = false`. When flipping a module on, resource references elsewhere need the `[0]` index (see `azurerm_kubernetes_cluster.infra[0].identity` pattern in `modules/k8s_cluster/main.tf`).
- `output.tf` is currently empty.

### CI/CD

Two GitHub Actions workflows (`.github/workflows/`) both read the workspace matrix from `config.yaml` (`workspaces[].name`/`path`) via `yq`/`jq`, then invoke `task -t ./taskfiles/tasks/terraform.yml workspaces` (from the external `bradfordwagner/taskfiles` repo) for each workspace:
- `terraform_workspaces_branches.yml` — runs on every push/dispatch, `tf_action=plan` against `target_tag=latest`.
- `terraform_workspaces_tags.yml` — runs on tag push, `tf_action=apply` against `target_tag=${{ github.ref_name }}`.

Both authenticate to Azure via Vault (`https://bradfordwagner.com:8200`, AppRole login) using `ROLE_ID`/`SECRET_ID` secrets; `config.yaml`'s `secrets.auth.approle.role` / `secrets.kv` describe which Vault role and KV path back that login.

There is also an Argo Workflow (`workflow.yaml`) that runs the same terraform apply out-of-band by checking out this repo at a given git ref/tag and running it in a `quay.io/bradfordwagner/terraform` image via a shared `flavor-terraform-template`.
