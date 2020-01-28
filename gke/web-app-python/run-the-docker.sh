#!/bin/bash

echo "docker build . -t gcr.io/amiteinav-sandbox/simpleapp"
docker build . -t gcr.io/amiteinav-sandbox/simpleapp
echo "docker push gcr.io/amiteinav-sandbox/simpleapp"
docker push gcr.io/amiteinav-sandbox/simpleapp 
echo "docker run -p 8000:8000 gcr.io/amiteinav-sandbox/simpleapp"
docker run -p 8000:8000 gcr.io/amiteinav-sandbox/simpleapp