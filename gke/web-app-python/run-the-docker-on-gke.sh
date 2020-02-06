#!/bin/bash

bash ../auth_cluster.sh

NAME=simpleapp
PORT=8000

echo "docker build . -t gcr.io/amiteinav-sandbox/simpleapp"
docker build . -t gcr.io/amiteinav-sandbox/simpleapp
echo "docker push gcr.io/amiteinav-sandbox/simpleapp"
docker push gcr.io/amiteinav-sandbox/simpleapp 

kubectl delete svc $NAME
kubectl delete deployment $NAME

echo "kubectl apply -f simpleapp.yaml"
kubectl apply -f simpleapp.yaml

echo "Getting service IP"
while [ "${IP}" == "" ] ; do
    IP=`kubectl get services $NAME --output jsonpath='{.status.loadBalancer.ingress[0].ip}'`
    sleep 2
    echo -n '.'
done;
echo "Now running curl http://${IP}:${PORT}"
curl http://${IP}:${PORT}

