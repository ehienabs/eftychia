
# Eftychia

## Table of Contents
+ [About](#about)
+ [Getting Started](#getting_started)
+ [Provisioning the Infrastructure](#provision_infra)
+ [Usage](#usage)

## About <a name = "about"></a>
Eftychia provisions the cloud infrastructure for bootstraping a Kubernetes cluster on Azure. She only provisions the compute resources —VMs, Load Balancer, Disks etc., not a functioning kubernetes cluster.
The components, networking routes, certificate authority etc., that does scheduling and pod maintainance will need to be installed separately.


## Getting Started <a name = "getting_started"></a>
After cloning the repo, to run Terraform locally, you first authenticate using the command line (for dev and testing), then configure the Azure provider.

[Authenticating with Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)

### Prerequisites
* [An Azure Subscription ](https://signup.azure.com/signup?offer=ms-azr-0044p&appId=102&ref=azureplat-generic&redirectURL=https%3A%2F%2Fazure.microsoft.com%2Fen-gb%2Fget-started%2Fwelcome-to-azure%2F&l=en-gb&correlationId=806a9c175f4749a2ad067a2ff7b52cad)
* [Azure command line](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Provisioning the infrastructure <a name = "provision_infra"></a>

After configuring the provider, you can assign variables by editing the [terraform.tfvars](infra/terraform.tfvars) file, then declaring them using the [variables.tf](infra/variables.tf) file.
Running `terraform apply` within the [infra](/infra) directory provisions the resources.

## Usage <a name = "usage"></a>

Eutuxia provisions the following compute resources:
* One Virtual Network
* One Subnet within the Network
* One Security Group and its Security rules
* One Load Balancer
* One Storage Container to keep the state file
* Two Availabilty Sets
* Five Virtual Machines and their SSH keys. (Two Control VMs and three Worker VMs)
* Five Disks
* Five Network Interfaces
* Six Static Ip addresses

<img width="935" alt="Annotation 2021-10-13 110707" src="https://user-images.githubusercontent.com/78366369/143015222-f56e8077-ec43-4f81-ba15-dde417af8cd8.png">

<img width="945" alt="Annotation 2021-10-13 110637" src="https://user-images.githubusercontent.com/78366369/143015267-3b585018-3d4f-49eb-a104-b2f13e5176f8.png">
