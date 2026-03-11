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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| helm | >= 2.0 |
| kubernetes | >= 2.0 |
| local | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| helm | 3.1.1 |
| kubernetes | 3.0.1 |
| local | 2.7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| ctx | ../_shared/platform-context | n/a |
| kubeconfig | ../vcluster-kubeconfig | n/a |
| platform\_registration | ../vcluster-platform-registration | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.vcluster](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace_v1.vcluster](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [local_sensitive_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [kubernetes_secret_v1.vcluster_kubeconfig](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the vCluster. Must be a valid Kubernetes resource name. | `string` | n/a | yes |
| chart\_version | vCluster Helm chart version to deploy. When null, the latest version from the Helm repository is used. | `string` | `null` | no |
| create\_namespace | Whether to create the Kubernetes namespace. Set to false if the namespace already exists. | `bool` | `true` | no |
| helm\_chart | Helm chart name to deploy | `string` | `"vcluster"` | no |
| helm\_repository | Helm repository URL for the vCluster chart | `string` | `"https://charts.loft.sh"` | no |
| helm\_timeout | Helm install/upgrade timeout in seconds | `number` | `600` | no |
| helm\_values | List of Helm values as YAML strings. Each entry is passed as a separate -f/--values argument. | `list(string)` | `[]` | no |
| kubeconfig\_output\_path | Filesystem path where the kubeconfig will be written. Defaults to <name>-kubeconfig.yaml in the root module directory. | `string` | `""` | no |
| kubeconfig\_secret\_name | Name of the Kubernetes secret containing the vCluster kubeconfig (OSS mode). Defaults to 'vc-<name>' if empty. | `string` | `""` | no |
| namespace | Kubernetes namespace for the vCluster. Defaults to <name>-ns when empty. | `string` | `""` | no |
| namespace\_labels | Additional labels to apply to the namespace. Merged with default labels (app.kubernetes.io/managed-by, app.kubernetes.io/name). | `map(string)` | `{}` | no |
| platform\_access\_key | Access key for authenticating with the vCluster Platform API. Required when platform\_url is set. | `string` | `""` | no |
| platform\_insecure | Whether to skip TLS verification for platform API calls. Only use for development. | `bool` | `false` | no |
| platform\_url | URL of the vCluster Platform (e.g., https://my-platform.loft.host). Leave empty for standalone (OSS) mode. | `string` | `""` | no |
| project\_name | vCluster Platform project name (without 'p-' prefix). Required when platform\_url is set. | `string` | `""` | no |
| retry\_attempts | Number of retry attempts for platform API calls (kubeconfig fetch, access key fetch). Increase if vClusters take longer to become available. | `number` | `5` | no |
| retry\_max\_delay\_ms | Maximum delay in milliseconds between retry attempts for platform API calls. | `number` | `15000` | no |
| retry\_min\_delay\_ms | Minimum delay in milliseconds between retry attempts for platform API calls. | `number` | `5000` | no |
| skip\_kubeconfig | Skip fetching kubeconfig entirely. When true, all kubeconfig-related outputs return empty values. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| access\_key | Platform-issued access key for the vCluster. Empty when platform is not used. |
| client\_certificate | PEM-encoded client certificate (base64-decoded) |
| client\_key | PEM-encoded client key (base64-decoded) |
| cluster\_ca\_certificate | PEM-encoded cluster CA certificate (base64-decoded) |
| host | Kubernetes API server URL from the kubeconfig. Use as 'host' in provider blocks. |
| insecure\_skip\_tls\_verify | Whether TLS verification is disabled in the kubeconfig |
| kubeconfig\_content | Raw kubeconfig YAML content |
| kubeconfig\_path | Filesystem path to the written kubeconfig file |
| name | Name of the vCluster |
| namespace | Kubernetes namespace where the vCluster is deployed |
| project\_namespace | Platform project namespace (with 'p-' prefix). Empty when platform is not used. |
| ready | Readiness marker. Use with depends\_on to sequence downstream resources. |
| token | Bearer token for Kubernetes API authentication |
<!-- END_TF_DOCS -->
