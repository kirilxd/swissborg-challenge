# Task 1
In order to provision local kubernetes cluster Minikube was used. Minikube is a lightweight Kubernetes implementation that creates a VM on your local machine and deploys a simple cluster containing only one node. It works well for the purpose of testing.

To start minikube the following command was executed:

`minikube start -p swissborg`

Next step was creating Terraform manifest `terraform/providers.tf` and running `terraform init` to initialize kubernetes provider with specified params.

Resources used:
https://medium.com/rahasak/terraform-kubernetes-integration-with-minikube-334c43151931

# Task 2

In order to install argocd three steps were performed:

1. Define `helm` provider in `terraform/provider.tf`
2. Add initial application definition in `argocd/application.yaml`
3. Define ArgoCD installation in `terraform/argo.tf`. It uses helm to install argocd and specifies `argocd/application.yaml` as values file

Resources used: https://piotrminkowski.com/2022/06/28/manage-kubernetes-cluster-with-terraform-and-argo-cd/

# Task 3 

To install traefik in cluster with argocd `argocd/traefik.yaml` which after applying creates argocd application with inflated helm chart taken from `source:`

Resources used:
* https://argo-cd.readthedocs.io/en/stable/user-guide/helm/
* https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-helm-chart

# Task 4

Keycloak was installed to the cluster by applying `argocd/keycloak.yaml`. Helm parameters were specified to set default username and password for admin.

After installing, I ran `kubectl port-forward svc/keycloak-http 8080:80 -n identity` to access keycloak admin console in the browser and verify that it's working properly.

Resources used:
https://www.keycloak.org/getting-started/getting-started-kube

# Task 5

To deploy postgresql to the cluster I applied argocd configuration in `argocd/postgresql.yaml` which uses `postgresql` helm chart from https://charts.bitnami.com/bitnami.
This chart provides PVC for data storage which ensures that data persists across pod restarts and deployments, and integrates well with dynamic volume provisioning in Kubernetes.