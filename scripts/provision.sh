#!/bin/bash

apt -y update
DEBIAN_FRONTEND=noninteractive apt -y install zip ca-certificates curl
echo "c3-ec2-controller" > /etc/hostname
hostname "c3-ec2-controller"

### awscliv2
curl --silent "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install

### kubectl
curl --silent -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

### Setup kubectl for particular EKS
aws eks --region ${region_name} update-kubeconfig --name ${eks_cluster_name}

### Setup k8s resources
/usr/local/bin/kubectl --kubeconfig /root/.kube/config create namespace c3

cat > /tmp/serviceaccount.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: c3
  namespace: c3
  annotations: 
    eks.amazonaws.com/role-arn: ${evl_job_iam_role_arn}
EOF
/usr/local/bin/kubectl --kubeconfig /root/.kube/config apply -f /tmp/serviceaccount.yaml

### Download install script
aws s3 cp s3://${evl_s3_bucket_name}/evl_install.sh .

### Run install script
/bin/bash evl_install.sh ${evl_app_version} ${evl_s3_bucket_name}

