#!/bin/bash

exec > >(tee /var/log/docker-setup.log)
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'

# Set Vars
accoundId=""
image=""
tag=""

# Uninstall Old Docker Version
yum remove -y docker
yum remove -y docker-common
yum remove -y docker-selinux
yum remove -y docker-engine

# Configure Repos
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
echo "" >> /etc/yum.repos.d/docker-ce.repo
echo "[centos-extras]" >> /etc/yum.repos.d/docker-ce.repo
echo "name=Centos extras - \$basearch" >> /etc/yum.repos.d/docker-ce.repo
echo "baseurl=http://mirror.centos.org/centos/7/extras/x86_64" >> /etc/yum.repos.d/docker-ce.repo
echo "enabled=1" >> /etc/yum.repos.d/docker-ce.repo
echo "gpgcheck=0" >> /etc/yum.repos.d/docker-ce.repo

# Install Dependencies
yum install -y curl
yum install -y unzip
yum install -y slirp4netns
yum install -y fuse-overlayfs 
yum install -y container-selinux

# Install Docker Engine
yum install -y docker-ce

# Enable docker
systemctl enable --now docker.service

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Get Authentication Token for AWS ECR
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $accountId.dkr.ecr.$region.amazonaws.com

# Pull Container Images
docker pull $accountId.dkr.ecr.region.amazonaws.com/$image:$tag

echo END
