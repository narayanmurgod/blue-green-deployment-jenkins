# blue-green-deployment-jenkins

**Personal Notes:**
1. Generate a GCE default service account key and add it to Jenkins as a secret file named "terraform-sa-key".
2. Install Terraform on the Jenkins server.
3. Install kubectl and the required authentication plugin using the references below:

**Installation References:**
1. Install Google Cloud SDK https://cloud.google.com/sdk/docs/install#deb
2. Configure kubectl access for GKE clusters https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#apt_1
