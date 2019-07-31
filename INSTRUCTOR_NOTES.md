# Instructor Notes - Classroom Lab Setup

*IMPORTANT*: Don't assume your classroom environment works. We've done everything possible to ensure that all of the content and workstations are tested, but sometimes things outside of our control can break things. Always log onto one of your workstations the night before (or morning of) your training and make sure you can fetch credentials, and run terraform commands from one of the workstations.

## What is this thing?
se-training-lab is a virtual classroom environment where you can quickly create Windows 10 workstations with HashiCorp tools pre-installed and ready to use. Windows was chosen as the OS because it commands [75% of the market share](https://www.statista.com/statistics/218089/global-market-share-of-windows-7/) for desktop operating systems. Windows 10 will be familiar and easy to use for the greatest number of users. These cloud desktop workstations are easy to use and provide a consistent environment for the benefit of instructors and students. The workstation image is currently published in two regions, **centralus** and **uksouth**. These workstations can be used with pre-built training curriculum such as https://github.com/hashicorp/se-terraform-vault-workshop or any other lab exercise that requires Terraform or Vault command line tools.

![HashiCorp Windows 10 Cloud Workstation](https://github.com/hashicorp/se-terraform-vault-workshop/blob/master/windows_workstation.png)

## Setting up the lab
If you have access to the HashiCorp Azure Demo environment, you can simply browse to the Azure Dev/Test labs section and click on *se-training-lab*, *emea-training-lab*, or *apac-training-lab*. If you're a partner or external user please contact your partner team representative for help setting this up in your own account. Once you've got your custom Windows 10 image the process is pretty simple:

1. Enter your Azure Dev/Test lab page on the Azure portal.
1. Click on the blue plus sign at the top of the page: `+Add`
1. Browse to the standard SE training workstation image. It's named `selabworkstation`. This is a shared Azure Image Gallery image that is published to both centralus and uksouth.
1. Give the virtual machine a name. Pick something simple and short, preferably without special characters.
1. For user name enter `hashicorp`
1. For the password you can set your own. Make sure it meets the complexity requirements for Windows 10.
1. Under more options, click *Change Size* and select the *B2ms* class of machine. This size has 8GB of RAM which is enough for Windows 10.
1. Back up at the top click on Advanced Settings.
1. Change the ip address type to *Public*.
1. Set a deletion date. This is the date when your lab machines will be destroyed. 
1. Set the number of instances to the number of participants in your workshop, plus a few extras just in case.
1. Hit the Submit button at the bottom.
1. Wait about 15-20 minutes. When your machines are done building you'll see a little notification icon in the upper right corner.
1. Distribute the public URLs, username, and password to your students.

### Optional Workstation DNS Names:
Use the se-classroom-lab terraform code to give your workstations custom *hashidemos.io* DNS names: https://github.com/hashicorp/se-classroom-lab

## Building an Azure Windows 10 Workstation - Packer
NEW: We now have a Packer template for building the workstation image. Standard Windows 10 workstation images are now published to different regions. You can find the source code and CI/CD pipeline here:

https://github.com/hashicorp/se-training-workstation
https://circleci.com/gh/hashicorp/se-training-workstation
