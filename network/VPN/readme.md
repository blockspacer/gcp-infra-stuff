
# Building a High-throughput VPN
1. Create secure, high-throughput VPN
2. Test the speed
3. Test the connections


## Create the VPN tunnels

* Set project to work on
```
PROJECT=amiteinav-sandbox
gcloud config set project $PROJECT
```
* Create a VPC named cloud
```
gcloud compute networks create cloud --subnet-mode custom
```
* Enable SSH and icmp
```
gcloud compute firewall-rules create cloud-fw --network cloud --allow tcp:22,tcp:5001,udp:5001,icmp
```
* Create a subnet within this VPC and specify a region and IP range by running:
```
gcloud compute networks subnets create cloud-east --network cloud \
    --range 10.0.1.0/24 --region us-east1
```
* Create a VPC named on-prem
gcloud compute networks create on-prem --subnet-mode custom

* Enable ssh and icmp
```
gcloud compute firewall-rules create on-prem-fw --network on-prem --allow tcp:22,tcp:5001,udp:5001,icmp
```
* Specify the subnet prefix for the region
```
gcloud compute networks subnets create on-prem-central \
    --network on-prem --range 192.168.1.0/24 --region us-central1
```
* Create a VPN gateway named on-prem-gw1 in the on-prem VPC and us-central1 region
```
gcloud compute target-vpn-gateways create on-prem-gw1 --network on-prem --region us-central1
```
* Create a VPN gateway named cloud-gw1 in the cloud VPC and us-east1 region
```
gcloud compute target-vpn-gateways create cloud-gw1 --network cloud --region us-east1
```

* Allocate IP for the cloud-gw1 VPN gateway
```
gcloud compute addresses create cloud-gw1 --region us-east1
```
* Allocate IP for the on-prem-gw1 VPN gateway
```
gcloud compute addresses create on-prem-gw1 --region us-central1
```
* Store the IPs for a later reference
```
cloud_gw1_ip=$(gcloud compute addresses describe cloud-gw1 \
    --region us-east1 --format='value(address)')
on_prem_gw_ip=$(gcloud compute addresses describe on-prem-gw1 \
    --region us-central1 --format='value(address)')
```

* Forward the Encapsulating Security Payload (ESP) protocol from cloud-gw1
```
gcloud compute forwarding-rules create cloud-1-fr-esp --ip-protocol ESP \
    --address $cloud_gw1_ip --target-vpn-gateway cloud-gw1 --region us-east1
```
* Forward UDP:500 traffic from cloud-gw1 (ISAKMP)
```
gcloud compute forwarding-rules create cloud-1-fr-udp500 --ip-protocol UDP \
    --ports 500 --address $cloud_gw1_ip --target-vpn-gateway cloud-gw1 --region us-east1
```
* Forward UDP:4500 traffic from cloud-gw1 (IPsec NAT traversal)
```
gcloud compute forwarding-rules create cloud-fr-1-udp4500 --ip-protocol UDP \
    --ports 4500 --address $cloud_gw1_ip --target-vpn-gateway cloud-gw1 --region us-east1
```

* Forward the ESP protocol from on-prem-gw1
```
gcloud compute forwarding-rules create on-prem-fr-esp --ip-protocol ESP \
    --address $on_prem_gw_ip --target-vpn-gateway on-prem-gw1 --region us-central1
```
* Forward UDP:500 traffic, used in establishing the IPsec tunnel from on-prem-gw1
```
gcloud compute forwarding-rules create on-prem-fr-udp500 --ip-protocol UDP --ports 500 \
    --address $on_prem_gw_ip --target-vpn-gateway on-prem-gw1 --region us-central1
```

* Forward UDP:4500 traffic, which carries the encrypted traffic from on-prem-gw1
```
gcloud compute forwarding-rules create on-prem-fr-udp4500 --ip-protocol UDP --ports 4500 \
    --address $on_prem_gw_ip --target-vpn-gateway on-prem-gw1 --region us-central1
```

* Create the VPN tunnel from on-prem to cloud
```
gcloud compute vpn-tunnels create on-prem-tunnel1 --peer-address $cloud_gw1_ip \
    --target-vpn-gateway on-prem-gw1 --ike-version 2 --local-traffic-selector 0.0.0.0/0 \
    --remote-traffic-selector 0.0.0.0/0 --shared-secret=sharedsecret --region us-central1
```
* Create the VPN tunnel from cloud to on-prem
```
gcloud compute vpn-tunnels create cloud-tunnel1 --peer-address $on_prem_gw_ip \
    --target-vpn-gateway cloud-gw1 --ike-version 2 --local-traffic-selector 0.0.0.0/0 \
    --remote-traffic-selector 0.0.0.0/0 --shared-secret=sharedsecret --region us-east1
```

* Route traffic from the on-prem VPC to the cloud 10.0.1.0/24 range into the tunnel
```
gcloud compute routes create on-prem-route1 --destination-range 10.0.1.0/24 \
    --network on-prem --next-hop-vpn-tunnel on-prem-tunnel1 \
    --next-hop-vpn-tunnel-region us-central1
```

* Route traffic from the cloud VPC to the on-prem 192.168.1.0/24 range into the tunnel
```
gcloud compute routes create cloud-route1 --destination-range 192.168.1.0/24 \
    --network cloud --next-hop-vpn-tunnel cloud-tunnel1 --next-hop-vpn-tunnel-region us-east1
```

## Test throughput over VPN
At this point, you've established a secure path between the on-prem and cloud VPCs. To test throughput use iperf, an open-source tool for network load testing. To test, you'll need a VM in each environment, one to send traffic and the other to receive it.

* Create a VM at us-east1 (cloud VPN)
```
gcloud compute instances create "cloud-loadtest" --zone "us-east1-b" \
    --machine-type "n1-standard-4" --subnet "cloud-east" \
    --image "debian-9-stretch-v20180814" --image-project "debian-cloud" --boot-disk-size "10" \
    --boot-disk-type "pd-standard" --boot-disk-device-name "cloud-loadtest"
```
* Create a VM at us-central1 (on-prem VPN)
```
gcloud compute instances create "on-prem-loadtest" --zone "us-central1-a" \
    --machine-type "n1-standard-4" --subnet "on-prem-central" \
    --image "debian-9-stretch-v20180814" --image-project "debian-cloud" --boot-disk-size "10" \
    --boot-disk-type "pd-standard" --boot-disk-device-name "on-prem-loadtest"
```
* ssh into the us-east1 VM
```
gcloud compute ssh cloud-loadtest --zone us-east1-b
```
* install iperf on the us-east1 VM
```
sudo apt-get install iperf
```
* ssh into the us-central1 VM
```
gcloud compute ssh on-prem-loadtest --zone us-central1-a
```
* install iperf on the us-east1 VM
```
sudo apt-get install iperf
```
* On the on-prem-loadtest VM, run this command (reports server status every 5 seconds)
```
iperf -s -i 5
```
* on the us-central1-a VM, create an iperf client with twenty streams, which will report values after 10 seconds of testing
```
iperf -c 192.168.1.2 -P 20 -x C
```

## Connectivity test
* you can test connectivity with the Console - https://cloud.google.com/network-intelligence-center/docs/connectivity-tests/how-to/running-connectivity-tests

* Choose the source VM and destination VM with the port 5001 and the UDP protocl - the test should work

* When choosing port 80 and TCP protocol - the test will faile
* To make it work, create a new FW 
```
gcloud compute firewall-rules create on-prem-fw-80 --network on-prem --allow tcp:80
```
* Try again the test - it should work!


