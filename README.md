# vCluster Terraform Modules

Production-ready Terraform modules for deploying and managing vClusters — standalone (OSS) or with vCluster Platform integration.

## Modules

| Module | Description |
|--------|-------------|
| [vcluster](vcluster/) | Complete vCluster deployment: namespace, Helm install, kubeconfig. Optional platform registration for Pro features. |
| [vcluster-kubeconfig](vcluster-kubeconfig/) | Fetch and write a vCluster kubeconfig from the Platform API |
| [vcluster-platform-registration](vcluster-platform-registration/) | Register an external vCluster with vCluster Platform for Pro features |
| [single-namespace-rename](single-namespace-rename/) | Translate vCluster resource names for single-namespace mode |

## Usage

### With vCluster Platform

```hcl
module "my_vcluster" {
  source = "git::https://github.com/loft-sh/vcluster-terraform-modules.git//vcluster"

  name                = "my-vcluster"
  project_name        = "default"
  platform_url        = "https://my-platform.loft.host"
  platform_access_key = var.platform_access_key

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

Deploy a vCluster without platform registration. The kubeconfig is read from a Kubernetes secret created by vCluster's `exportKubeConfig` Helm values feature.

```hcl
module "my_vcluster" {
  source = "git::https://github.com/loft-sh/vcluster-terraform-modules.git//vcluster"

  name        = "my-vcluster"
  helm_values = [file("${path.module}/vcluster-values.yaml")]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
