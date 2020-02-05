#!/bin/bash

bash ../auth_cluster.sh

echo "docker build . -t gcr.io/amiteinav-sandbox/simpleapp"
docker build . -t gcr.io/amiteinav-sandbox/simpleapp
echo "docker push gcr.io/amiteinav-sandbox/simpleapp"
docker push gcr.io/amiteinav-sandbox/simpleapp 

kubectl run simpleapp --image=gcr.io/amiteinav-sandbox/simpleapp --replicas=2 --port=8000
kubectl expose deployment simpleapp --port=8000 --type=LoadBalancer
kubectl get services --watch


