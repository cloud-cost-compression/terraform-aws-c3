#!/bin/bash

EVL_VERSION="${1}"

AWS_IAM_ROLE_ARN="${2}"

REGION_NAME="${3}"

EKS_CLUSTER_NAME="${4}"

### k8s-resources
aws eks --region $REGION_NAME update-kubeconfig --name $EKS_CLUSTER_NAME

kubectl create namespace c3

cat > /tmp/serviceaccount.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: c3
  namespace: c3
  annotations: 
    eks.amazonaws.com/role-arn: ${AWS_IAM_ROLE_ARN}
EOF
kubectl apply -f /tmp/serviceaccount.yaml

### evl-dependencies 
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends \
  apt-utils ssh gcc g++ libstdc++6 libc6 libgcc-s1 \
  zlib1g gettext-base binutils coreutils findutils \
  util-linux bsdmainutils libncurses5-dev procps \
  dos2unix zlib1g-dev libxml2 libicu-dev libsnappy-dev \
  libcrypto++-dev postgresql-client sqlite3 ca-certificates lsb-release wget git

wget https://apache.jfrog.io/artifactory/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb
DEBIAN_FRONTEND=noninteractive apt -y install -V ./apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb
apt -y update
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends libparquet-dev

### evl
aws s3 sync s3://evl-ubuntu/${EVL_VERSION}/ ./evl-ubuntu/
DEBIAN_FRONTEND=noninteractive apt -y install \
  ./evl-ubuntu/evl-utils*.deb \
  ./evl-ubuntu/evl-tool*.deb \
  ./evl-ubuntu/evl-data*.deb \
  ./evl-ubuntu/evl-parquet*.deb
 
rm -rf /var/lib/apt/lists/*
apt -y clean

/opt/evl/bin/evl --init
source $HOME/.evlrc
