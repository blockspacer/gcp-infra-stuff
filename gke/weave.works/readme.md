# Weave Scope by weaveworks
Ref: https://github.com/weaveworks/scope

## Overview
Weave Scope is a visualization and monitoring tool for Docker and Kubernetes. 
It provides a top down view into your app as well as your entire infrastructure, and allows you to diagnose any problems with your distributed containerized app, in real time, as it is being deployed to a cloud provider.

## Installation instructions on GKE
Ref: https://www.weave.works/docs/scope/latest/installing/#k8s

* Get Clusters credentials (Example, replace CLUSTERS's value with the real name of the clusters)
```
CLUSTERS="mci-us-central-cluster mci-europe-west-cluster"
PROJECT_ID=`gcloud config get-value project`

for cluster in $CLUSTERS ; do
    export ZONE=`gcloud container clusters list --format="value(zone)" \
    --filter="name:${cluster}"` ; \
    KUBECONFIG=clusters.yaml gcloud container clusters \
    get-credentials $cluster --zone=$ZONE  
done

* On each cluster, grant Permissions to install 
```
for ctx in $(kubectl config get-contexts -o=name --kubeconfig clusters.yaml); do
  kubectl --kubeconfig clusters.yaml --context="${ctx}"  create \
  clusterrolebinding "cluster-admin-$(whoami)" \
  --clusterrole=cluster-admin \
  --user="$(gcloud config get-value core/account)"
done
```

* On each cluster, install the weave scope 
```
for ctx in $(kubectl config get-contexts -o=name --kubeconfig clusters.yaml); do
  kubectl --kubeconfig clusters.yaml --context="${ctx}"  apply \
  -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=\
$(kubectl version | base64 | tr -d '\n')"
done
```

* To open Scope in Your Browser
```
kubectl port-forward -n weave \
"$(kubectl get -n weave pod --selector=weave-scope-component=app \
-o jsonpath='{.items..metadata.name}')" 4040
```
Note: Do not expose the Scope service to the Internet, e.g. by changing the type to NodePort or LoadBalancer. Scope allows anyone with access to the user interface control over your hosts and containers.


