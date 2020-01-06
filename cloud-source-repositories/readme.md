# Jenkins and Cloud Source Repositories
https://google.qwiklabs.com/focuses/1103?parent=catalog

## Setting up ssh authentication Cloud Source Repositories

* create a repository
```
REPO_NAME=demo-repo-$RANDOM
gcloud source repos create $REPO_NAME
```
* Generate a key pair
```
USER_EMAIL=amiteinav@google.com
ssh-keygen -t rsa -C "${USER_EMAIL}"
```
* View the rsa files
```
cat ~/.ssh/id_rsa.pub
cat ~/.ssh/id_rsa
```
* Register the public key on the repository (Manage SSH Key->register SSH) - done once per project

* setup to code import into the repo
```
cd ~/continuous-deployment-on-kubernetes/sample-app
git config --global credential.'https://source.developers.google.com'.helper gcloud.sh
git remote add origin ssh://amiteinav@google.com@source.developers.google.com:2022/p/amiteinav-sandbox/r/${REPO_NAME}
```

* Adding to the repository 
```
git add .
git commit -m "Initial commit"
git push --all origin

```
* Pushing code to Cloud Source Repositories
```
git push --all origin
```
* Cloning a repository
```
PROJECT_NAME=$(gcloud config get-value project)
git clone ssh://${USER_EMAIL}@source.developers.google.com:2022/p/${PROJECT_ID}/r/${REPO_NAME}
```


