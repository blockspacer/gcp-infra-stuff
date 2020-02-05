PROJECT_ID=`gcloud config get-value project`
gcloud beta compute \
--project=${PROJECT_ID} instances create instance-std \
 --zone=asia-south1-c --machine-type=f1-micro --network network-latency-test-vpc \
  --subnet=asia-south1 \
  --network-tier=STANDARD \
  --maintenance-policy=MIGRATE \
   --service-account=185061819993-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --image=debian-9-drawfork-v20191004 --image-project=eip-images --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name=instance-6 \
    --reservation-affinity=any