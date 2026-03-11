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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| http | >= 3.2 |
| local | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| http | 3.5.0 |
| local | 2.7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| ctx | ../_shared/platform-context | n/a |

## Resources

| Name | Type |
|------|------|
| [local_sensitive_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [http_http.kubeconfig](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| platform\_access\_key | Access key for authenticating with the vCluster Platform API | `string` | n/a | yes |
| platform\_url | URL of the vCluster Platform (e.g., https://my-platform.loft.host). Scheme is added automatically if omitted. | `string` | n/a | yes |
| project\_name | vCluster Platform project name (without 'p-' prefix) | `string` | n/a | yes |
| vcluster\_name | Name of the vCluster to fetch the kubeconfig for | `string` | n/a | yes |
| certificate\_ttl | TTL in seconds for the generated kubeconfig certificate. Defaults to 86400 (24 hours). Lower values are recommended for production environments. | `number` | `86400` | no |
| output\_path | Filesystem path where the kubeconfig file will be written. Defaults to <vcluster\_name>-kubeconfig.yaml in the module directory. | `string` | `""` | no |
| platform\_insecure | Whether to skip TLS verification for platform API calls. Only use for development. | `bool` | `false` | no |
| retry\_attempts | Number of retry attempts for the kubeconfig API call. The vCluster API may not be immediately available through the platform proxy after deployment. | `number` | `5` | no |
| retry\_max\_delay\_ms | Maximum delay in milliseconds between retry attempts. | `number` | `15000` | no |
| retry\_min\_delay\_ms | Minimum delay in milliseconds between retry attempts. | `number` | `5000` | no |

## Outputs

| Name | Description |
|------|-------------|
| client\_certificate | PEM-encoded client certificate (base64-decoded from kubeconfig) |
| client\_key | PEM-encoded client key (base64-decoded from kubeconfig) |
| cluster\_ca\_certificate | PEM-encoded cluster CA certificate (base64-decoded from kubeconfig) |
| host | Kubernetes API server URL from the kubeconfig. Use as 'host' in provider blocks. |
| insecure\_skip\_tls\_verify | Whether TLS verification is disabled in the kubeconfig |
| kubeconfig\_content | Raw kubeconfig YAML content |
| kubeconfig\_path | Filesystem path to the written kubeconfig file |
| ready | Readiness marker. Use with depends\_on to sequence downstream resources. |
| token | Bearer token for Kubernetes API authentication |
<!-- END_TF_DOCS -->
