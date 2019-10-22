# Distributed load testing using Google Kubernetes Engine
ref: https://cloud.google.com/solutions/distributed-load-testing-using-gke

## About the load testing master
The Locust master is the entry point for executing the load testing tasks. The Locust master configuration specifies several elements, including the ports to be exposed by the container:
* 8089 for the web interface
* 5557 and 5558 for communicating with workers
This information is later used to configure the Locust workers.

After you deploy the Locust master, you can open the web interface using the public IP address of the external forwarding rule. After you deploy the Locust workers, you can start the simulation and look at aggregate statistics through the Locust web interface.

# Initializing common variables
* Replace the TARGET_HOST value in the following yaml files
  * locust-master-controller.yaml
  * locust-worker-controller.yaml
* Deploy the Locust master and worker nodes
```
kubectl apply -f locust-master-controller.yaml
kubectl apply -f locust-worker-controller.yaml
```
* Get the external IP
```
EXTERNAL_IP=$(kubectl get svc locust-master -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
```
* Use a browser to start the test
```
http://${EXTERNAL_IP}:8089/
```