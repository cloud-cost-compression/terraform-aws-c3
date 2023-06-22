#!/bin/bash

EVL_VERSION="${1}"

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

DEBIAN_FRONTEND=noninteractive apt -y install ./evl-ubuntu/evl-utils*.deb
DEBIAN_FRONTEND=noninteractive apt -y install ./evl-ubuntu/evl-tool*.deb
DEBIAN_FRONTEND=noninteractive apt -y install ./evl-ubuntu/evl-data*.deb
DEBIAN_FRONTEND=noninteractive apt -y install ./evl-ubuntu/evl-parquet*.deb

rm -rf /var/lib/apt/lists/*
apt -y clean

/opt/evl/bin/evl --init
source $HOME/.evlrc
