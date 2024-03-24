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
2. Add initial application definition in `argocd/application.yaml`. It contains path to local minikube cluster as `destination` and repo URL with `argocd/manifests/cluster` as source.
3. Define ArgoCD installation in `terraform/argo.tf`. It uses helm to install argocd and specifies `argocd/application.yaml` as values file.

After performing these steps ArgoCD UI can be accessed by port-forwarding respective argocd-server service.

Resources used: https://piotrminkowski.com/2022/06/28/manage-kubernetes-cluster-with-terraform-and-argo-cd/

# Task 3 

To install traefik in cluster manifest in `argocd/traefik.yaml` was applied. After installation it is possible to apply CRD called IngressRoute provided by traefik, which allows to configure HTTP routers. The one created is located in `argocd/ingress` and it allows to access argocd-server service via argocd.internal host with http.

Resources used:
* https://argo-cd.readthedocs.io/en/stable/user-guide/helm/
* https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-helm-chart
* https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/#kind-ingressroute

# Task 4

Keycloak was installed to the cluster by applying `argocd/keycloak.yaml`. Helm parameters were specified to set default username and password for admin.

After installing, I ran `kubectl port-forward svc/keycloak-http 8080:80 -n identity` to access keycloak admin console in the browser and verify that it's working properly. To configure keycloak for user authorization and authentication new realm was created in scope of which new clients are to be created for 

Resources used:
https://www.keycloak.org/getting-started/getting-started-kube

# Task 5

To deploy postgresql to the cluster I applied argocd configuration in `argocd/postgresql.yaml` which uses `postgresql` helm chart from https://charts.bitnami.com/bitnami.
This chart provides PVC for data storage which ensures that data persists across pod restarts and deployments, and integrates well with dynamic volume provisioning in Kubernetes.

# Task 6

As a starting point for deploying Retool application I took this official guide https://docs.retool.com/self-hosted/quickstarts/kubernetes/helm.

This is where a need for introducing secrets management appeared since private keys need to be defined for retool deployment. There are multiple ways how secrets can be handled in scope of argocd deployment (https://argo-cd.readthedocs.io/en/stable/operator-manual/secret-management/), but in scope of the challenge and considering that retool helm chart provides a convenient way to use opaque k8s secrets, I decided to go with them. Secrets setup was done as described in k8s documentation (https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-config-file/), applied `retool-secret.yaml` (it was edited with placeholder values to safely add it to VCS) manifest with kubectl and specified them in helm values in argocd application manifest. I also disabled workflows, code executor and chart's ingress as those are not needed in scope of the task and set replicas to 1 to save on the resources (default value of 2 caused overconsumption of RAM and made cluster unstable).

After deployment was set up I managed to access retool application and added postgresql db deployed previously as resource by accessing it via cluster IP.

![img.png](img/retool-db.png)

This allows to add the datasource to retool application and therefore use it as frontend for postgresql.

# Task 7

For this task I decided to go with `kube-prometheus-stack` helm chart. It includes Prometheus, Grafana, Alertmanager, node-exporter, kube-state-metrics and an adapter for Kubernetes Metrics API-s which allows for easy and configurable monitoring of cluster resources. To install the chart in the cluster I created argocd manifest in `argocd/prometheus.yaml`, set `podMonitorSelectorNilUsesHelmValues` and `serviceMonitorSelectorNilUsesHelmValues` values to false so that Prometheus to pick up all the Pod and Service monitoring across the cluster.
After applying the manifest I am able to login to grafana with the default admin credentials (password can be configured in helm values, but I am using the default one). When creating dashboard in grafana I can choose Prometheus (which is deployed as part of the stack) as a data source which scrapes information about cluster objects and create visualizations based on that.

![img.png](img/grafana.png)

# Production readiness

As ArgoCD is used in setting up the cluster if follows GitOps approach. We are storing all the configurations in version control which allows to restore the cluster in case of disaster. Most of the deployments used are provided as helm charts, which are open-source and supported by community that makes the reliable and secure. Also k8s secrets where used for defining secrets in configurations which is essential for keeping them safe.

Further steps to improve production readiness:

1. Minikube is a decent solution for provisioning local k8s cluster, but for production purposes another tool should be used (e.g. Kubernetes engines by cloud providers like GKE, EKS etc.). This will also allow to add more resources to the cluster on demand (there were some issues related to limited resources in Task 3).
2. More robust secrets management solution should be used. While k8s secrets provides allows to store secrets not exposing them to version control, it still stores unencrypted secrets in etcd which is considered security issue. Secrets operators like Vault can be deployed to the cluster and configured to solve this issue.
3. HTTPS should be introduced for publicly exposed ingress routes (Traefik provides such ability). This will include obtainig TLS certificate and specifying in Traefik manifest.
