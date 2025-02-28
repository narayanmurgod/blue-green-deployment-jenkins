# traffic-based-node-scaling

**Personal Notes:**
1. Generate a GCE default service account key and add it to Jenkins as a secret file named "terraform-sa-key".
2. Install Terraform on the Jenkins server. Don't forget to enable the check box "Allow full access to all Cloud APIs"
3. Install Terraform
4. Install kubectl and the required authentication plugin using the references below:

**Installation References:**
1. Install Google Cloud SDK https://cloud.google.com/sdk/docs/install#deb
2. Configure kubectl access for GKE clusters https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#apt_1



Let’s go to teminal jenkins server and run below command:

$ sudo visudo

jenkins ALL=(ALL) NOPASSWD: ALL

Jenkins: 403 No valid crumb was included in the request  https://stackoverflow.com/a/56167349



# Auth using SA key

gcloud auth login --no-launch-browser

gcloud config set project "<PROJECT_ID>"  

gcloud iam service-accounts create terraform \
    --description="Terraform Service Account" \
    --display-name="terraform"

export GOOGLE_SERVICE_ACCOUNT=`gcloud iam service-accounts list --format="value(email)"  --filter=description:"Terraform Service Account"` 

export GOOGLE_CLOUD_PROJECT=`gcloud info --format="value(config.project)"`

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="serviceAccount:$GOOGLE_SERVICE_ACCOUNT" \
    --role="roles/editor" 

gcloud iam service-accounts keys create "./terraform.json"  \
  --iam-account=$GOOGLE_SERVICE_ACCOUNT 

# service-account-impersonation

***Delete unused credentials locally***

unset GOOGLE_CREDENTIALS  

***Delete previously issued keys***

rm ../key-file/terraform.json
gcloud iam service-accounts keys list    --iam-account=$GOOGLE_SERVICE_ACCOUNT
gcloud iam service-accounts keys delete   <SERVICE ACCOUNT ID>  --iam-account=$GOOGLE_SERVICE_ACCOUNT

***Set up impersonation***

export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=`gcloud iam service-accounts list --format="value(email)"  --filter=name:terraform`

gcloud auth application-default login --no-launch-browser 

export USER_ACCOUNT_ID=`gcloud config get core/account` 

gcloud iam service-accounts add-iam-policy-binding \
    $GOOGLE_IMPERSONATE_SERVICE_ACCOUNT \
    --member="user:$USER_ACCOUNT_ID" \
    --role="roles/iam.serviceAccountTokenCreator"  

export GOOGLE_CLOUD_PROJECT=`gcloud info --format="value(config.project)"` 

Remove -refresh-only while running the pipeline for the first time in the Terraform apply stage.