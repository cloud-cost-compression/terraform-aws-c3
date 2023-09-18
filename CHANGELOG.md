## 2023-09-18 - Release 0.2.2
- Update s3 arn reference in ec2-controller policy to do not reference to s3 bucket module
- Add dependency to ec2 instance for controller iam policy
- Add manage_default_network_acl = false to module vpc
- Update desired number of worker nodes to 1
- Add aws eks wait nodegroup-active command to provision.sh.tftpl

## 2023-09-12 - Release 0.2.1
- Update ubuntu2004 to custom ami ubuntu2204 - temporary fix fo test purposes

## 2023-09-07 - Release 0.2.0
- Change AWS ami base image from amazonlinux2 to ubuntu2004 for eks worker
- Update path for scripts used by ec2-controller
- Add CHANGELOG.md
