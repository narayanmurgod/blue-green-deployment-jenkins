# traffic-based-node-scaling

**Personal Notes:**
1. Generate a GCE default service account key and add it to Jenkins as a secret file named "terraform-sa-key".
2. Install Terraform on the Jenkins server. Don't forget to enable the check box "Allow full access to all Cloud APIs"
3. Install Terraform
4. Install kubectl and the required authentication plugin using the references below:

**Installation References:**
1. Install Google Cloud SDK https://cloud.google.com/sdk/docs/install#deb
2. Configure kubectl access for GKE clusters https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#apt_1
