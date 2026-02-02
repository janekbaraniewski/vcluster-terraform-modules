# vCluster Platform Registration Module

Registers an external vCluster with the vCluster Platform, enabling Pro features via platform license.

## What it does

1. Registers the vCluster with the vCluster Platform
2. Provisions platform credentials for the vCluster
3. Stores the credentials as a Kubernetes secret in the vCluster namespace

## Usage

```hcl
module "vcluster_registration" {
  source = "git::https://github.com/loft-sh/vcluster-terraform-modules.git//vcluster-platform-registration"

  vcluster_name       = "my-vcluster"
  vcluster_namespace  = "my-vcluster-ns"
  project_name        = "default"
  platform_url        = "https://my-platform.loft.host"
  platform_access_key = var.platform_access_key
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| kubernetes | >= 2.0 |
| http | >= 3.2 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vcluster_name | Name of the vCluster to register | `string` | | yes |
| vcluster_namespace | Namespace where vCluster is deployed | `string` | | yes |
| project_name | vCluster Platform project name (without 'p-' prefix) | `string` | | yes |
| platform_url | URL of the vCluster Platform | `string` | | yes |
| platform_access_key | Platform API access key | `string` | | yes |
| vcluster_chart_version | vCluster Helm chart version | `string` | `null` (omitted) | no |
| platform_insecure | Skip TLS verification | `bool` | `false` | no |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| access_key | Platform-issued access key for the vCluster | yes |
| project_namespace | Platform project namespace (with 'p-' prefix) | no |
| platform_host | Platform hostname (without scheme) | no |
| platform_secret_name | Name of the created platform credentials secret | no |
| vci_name | Name of the created VirtualClusterInstance | no |
| completed | Readiness marker for depends_on | no |
