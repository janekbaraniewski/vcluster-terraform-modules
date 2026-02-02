# vCluster Module

Complete vCluster deployment with optional vCluster Platform integration.

## What it does

1. Creates a Kubernetes namespace for the vCluster
2. (Optional) Registers the vCluster with vCluster Platform for Pro features
3. Deploys vCluster via Helm
4. Fetches the vCluster kubeconfig (from the Platform API or a Kubernetes secret)

## Usage

### With vCluster Platform

```hcl
module "my_vcluster" {
  source = "git::https://github.com/loft-sh/vcluster-terraform-modules.git//vcluster"

  name                = "my-vcluster"
  project_name        = "default"
  platform_url        = "https://my-platform.loft.host"
  platform_access_key = var.platform_access_key

  # Optional
  helm_values = [file("${path.module}/vcluster-values.yaml")]
}

# Configure a provider using the vCluster credentials
provider "kubernetes" {
  alias                  = "vcluster"
  host                   = module.my_vcluster.host
  cluster_ca_certificate = module.my_vcluster.cluster_ca_certificate
  client_certificate     = module.my_vcluster.client_certificate
  client_key             = module.my_vcluster.client_key
}
```

### Standalone (OSS)

When `platform_url` is omitted, the module deploys a standalone vCluster without platform registration. The kubeconfig is read from a Kubernetes secret that vCluster creates via its `exportKubeConfig` feature.

You must include the `exportKubeConfig` section in your Helm values so that vCluster writes its kubeconfig to a secret:

```yaml
# vcluster-values.yaml
exportKubeConfig:
  context: my-vcluster
  server: https://localhost:8443
  secret:
    name: vc-my-vcluster   # must match kubeconfig_secret_name (default: vc-<name>)
```

```hcl
module "my_vcluster" {
  source = "git::https://github.com/loft-sh/vcluster-terraform-modules.git//vcluster"

  name        = "my-vcluster"
  helm_values = [file("${path.module}/vcluster-values.yaml")]
}

# Configure a provider using the vCluster credentials
provider "kubernetes" {
  alias                  = "vcluster"
  host                   = module.my_vcluster.host
  cluster_ca_certificate = module.my_vcluster.cluster_ca_certificate
  client_certificate     = module.my_vcluster.client_certificate
  client_key             = module.my_vcluster.client_key
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| kubernetes | >= 2.0 |
| helm | >= 2.0 |
| local | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name of the vCluster | `string` | | yes |
| project_name | vCluster Platform project name (without 'p-' prefix) | `string` | `""` | no |
| platform_url | URL of the vCluster Platform. Leave empty for OSS mode. | `string` | `""` | no |
| platform_access_key | Platform API access key | `string` | `""` | no |
| namespace | Namespace for vCluster (defaults to `<name>-ns`) | `string` | `""` | no |
| create_namespace | Create the namespace | `bool` | `true` | no |
| namespace_labels | Additional namespace labels | `map(string)` | `{}` | no |
| platform_insecure | Skip TLS verification for platform calls | `bool` | `false` | no |
| chart_version | vCluster Helm chart version | `string` | `null` (latest) | no |
| helm_repository | Helm repository URL | `string` | `"https://charts.loft.sh"` | no |
| helm_chart | Helm chart name | `string` | `"vcluster"` | no |
| helm_values | List of Helm values content (YAML strings) | `list(string)` | `[]` | no |
| helm_timeout | Helm timeout in seconds | `number` | `600` | no |
| kubeconfig_output_path | Path for kubeconfig file | `string` | `""` | no |
| kubeconfig_secret_name | Name of the K8s secret with kubeconfig (OSS mode, defaults to `vc-<name>`) | `string` | `""` | no |
| skip_kubeconfig | Skip fetching kubeconfig (outputs return empty values) | `bool` | `false` | no |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| name | Name of the vCluster | no |
| namespace | Namespace where vCluster is deployed | no |
| project_namespace | Platform project namespace (with 'p-' prefix). Empty in OSS mode. | no |
| access_key | Platform-issued access key. Empty in OSS mode. | yes |
| ready | Readiness marker for depends_on | no |
| kubeconfig_path | Filesystem path to the kubeconfig file | no |
| kubeconfig_content | Raw kubeconfig YAML content | yes |
| host | Kubernetes API server URL (for provider `host` argument) | no |
| cluster_ca_certificate | PEM-encoded cluster CA certificate | yes |
| client_certificate | PEM-encoded client certificate | yes |
| client_key | PEM-encoded client key | yes |
| token | Bearer token for API authentication | yes |
| insecure_skip_tls_verify | Whether TLS verification is disabled | no |

## Submodules

This module uses:
- [vcluster-platform-registration](../vcluster-platform-registration/) - Platform registration (when `platform_url` is set)
- [vcluster-kubeconfig](../vcluster-kubeconfig/) - Kubeconfig fetching from Platform API (when `platform_url` is set)
