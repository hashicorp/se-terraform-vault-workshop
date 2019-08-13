# Instructor Notes - Classroom Lab Setup

## What is this thing?
se-training-lab is a virtual classroom environment where you can quickly create Windows 10 workstations with HashiCorp tools pre-installed and ready to use. Windows was chosen as the OS because it commands [75% of the market share](https://www.statista.com/statistics/218089/global-market-share-of-windows-7/) for desktop operating systems. Windows 10 will be familiar and easy to use for the greatest number of users. These cloud desktop workstations are easy to use and provide a consistent environment for the benefit of instructors and students. The workstation image is currently published in one regions, **us-east-1**. These workstations can be used with pre-built training curriculum such as https://github.com/hashicorp/se-terraform-vault-workshop or any other lab exercise that requires Terraform or Vault command line tools.

![HashiCorp Windows 10 Cloud Workstation](https://github.com/hashicorp/se-terraform-vault-workshop/blob/master/windows_workstation.png)

## Setting up the lab

There is a `terraform` package included to deploy a workstation to AWS.


### Optional Workstation DNS Names:
Use the se-classroom-lab terraform code to give your workstations custom *hashidemos.io* DNS names: https://github.com/hashicorp/se-classroom-lab

## Building an Azure Windows 10 Workstation - Packer
NEW: We now have a Packer template for building the workstation image. Standard Windows 10 workstation images are now published to different regions. You can find the source code and CI/CD pipeline here:

https://github.com/hashicorp/se-training-workstation
https://circleci.com/gh/hashicorp/se-training-workstation