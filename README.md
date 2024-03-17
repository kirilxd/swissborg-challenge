# Task 1
In order to provision local kubernetes cluster Minikube was used. Minikube is a lightweight Kubernetes implementation that creates a VM on your local machine and deploys a simple cluster containing only one node. It works well for the purpose of testing.

To start minikube the following command was executed:

`minikube start -p swissborg`

Next step was creating Terraform manifest `terraform/providers.tf` and running `terraform init` to initialize kubernetes provider with specified params.