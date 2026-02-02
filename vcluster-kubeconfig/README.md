# vCluster Kubeconfig Module

Fetches and writes a vCluster kubeconfig from the vCluster Platform API.

## What it does

1. Fetches the vCluster kubeconfig from the vCluster Platform
2. Writes the kubeconfig to a local file
3. Exposes parsed credentials for direct use in Terraform provider configuration

## Usage

```hcl
module "vcluster_kubeconfig" {
  source = "git::https://github.com/loft-sh/vcluster-terraform-modules.git//vcluster-kubeconfig"

  vcluster_name       = "my-vcluster"
  project_name        = "default"
  platform_url        = "https://my-platform.loft.host"
  platform_access_key = var.platform_access_key

  # Optional: override the default kubeconfig file path
  output_path = "${path.module}/my-kubeconfig.yaml"
}

# Configure a Kubernetes provider using the parsed credentials
provider "kubernetes" {
  host                   = module.vcluster_kubeconfig.host
  cluster_ca_certificate = module.vcluster_kubeconfig.cluster_ca_certificate
  client_certificate     = module.vcluster_kubeconfig.client_certificate
  client_key             = module.vcluster_kubeconfig.client_key
}
```

The kubeconfig is also written to disk at `output_path` for use with external tools like `kubectl`.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| http | >= 3.2 |
| local | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vcluster_name | Name of the vCluster | `string` | | yes |
| project_name | vCluster Platform project name (without 'p-' prefix) | `string` | | yes |
| platform_url | URL of the vCluster Platform | `string` | | yes |
| platform_access_key | Platform API access key | `string` | | yes |
| output_path | Path for kubeconfig file | `string` | `""` | no |
| platform_insecure | Skip TLS verification | `bool` | `false` | no |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| kubeconfig_path | Filesystem path to the kubeconfig file | no |
| kubeconfig_content | Raw kubeconfig YAML content | yes |
| ready | Readiness marker for depends_on | no |
| host | Kubernetes API server URL (for provider `host` argument) | no |
| cluster_ca_certificate | PEM-encoded cluster CA certificate | yes |
| client_certificate | PEM-encoded client certificate | yes |
| client_key | PEM-encoded client key | yes |
| token | Bearer token for API authentication | yes |
| insecure_skip_tls_verify | Whether TLS verification is disabled | no |
