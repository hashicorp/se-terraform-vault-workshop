# Instructor Notes - Azure Terraform/Vault Workshop

## Setting up the lab
If you have access to the HashiCorp Azure Demo environment, you can simply browse to the Azure Dev/Test labs section and click on *se-training-lab*. If you're a partner or external user, skip down to the "Building an Azure Windows 10 Workstation" section to create a reusable custom image. Once you've got your custom Windows 10 image the process is pretty simple:

1. Enter your Azure Dev/Test lab page on the Azure portal.
1. Click on the blue plus sign at the top of the page: ➕`Add`
1. Browse to your workstation image. In the HashiCorp SE account it is called hc-training-workstation-2019-02-08-3
1. Give the virtual machine a name. Pick something simple and short, preferably without special characters.
1. For user name enter `hashicorp`
1. For the password you can set your own. Make sure it meets the complexity requirements for Windows 10.
1. Under more options, click *Change Size* and select the B2ms class of machine. This size has 8GB of RAM which is enough for windows 10.
1. Back up at the top click on Advanced Settings.
1. Change the ip address type to *Public*.
1. Set a deletion date. This is the date when your lab machines will be destroyed.
1. Set the number of instances to the number of participants in your workshop, plus a few extras just in case.
1. Hit the Submit button at the bottom.
1. Wait about 15-20 minutes. When your machines are done building you'll see a little notification icon in the upper right corner.
1. Distribute the public URLs, username, and password to your students.

## Building an Azure Windows 10 Workstation
Follow this process to build a Windows 10 workstation image in your own account or location.

1. Spin up a standard Windows 10 instance from the marketplace *inside Azure Dev/Test labs*. You'll use this as your base image. It's important that you create your machine inside the lab where you want to snapshot it. Once you're able to log onto the machine, run the steps below.

2. Run this script.
```
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install cmder -y
choco install git -y
choco install nmap -y
choco install 7zip -y
choco install putty -y
choco install openssh -y
choco install winscp -y
choco install visualstudiocode -y
choco install googlechrome -y
choco install poshgit -y

# Create a Desktop shortcut for Cmder
# Note: Set your default shell to Powershell the first time you run this.
$TargetFile = "C:\tools\cmder\Cmder.exe"
$ShortcutFile = "C:\Users\Public\Desktop\cmder.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()
```
3. Install vault and terraform in C:\windows\system32. That's right, just toss the binaries in there.
4. Install the Azure CLI
5. Make a service principal.  https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html
6. Run these powershell commands (as admin) with your credentials:
```
[Environment]::SetEnvironmentVariable("ARM_SUBSCRIPTION_ID", "c0a607b2-6372-4ef3-abdb-dbe52a7b56ba", "Machine")
[Environment]::SetEnvironmentVariable("ARM_CLIENT_ID", "e8e56057-d294-4540-8235-22064e1b3179", "Machine")
[Environment]::SetEnvironmentVariable("ARM_CLIENT_SECRET", "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "Machine")
[Environment]::SetEnvironmentVariable("ARM_TENANT_ID", "0e3e2e88-8caf-41ca-b4da-e3b33b6c52ec", "Machine")
```
7. Alteratively, manually configure these environment variables as *system* and not *user* env vars

```
ARM_SUBSCRIPTION_ID
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_TENANT_ID
```

8. Add a file called setup.ps1 inside of C:\Users\Public\Desktop. This will ensure that it shows up on your users desktop when you deploy new workstations:

```
# Post-install steps for HashiCorp training workstation
git config --global core.autocrlf false
Set-ExecutionPolicy Undefined -scope Process
Set-ExecutionPolicy Unrestricted -scope CurrentUser
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module posh-git -Force -SkipPublisherCheck -AllowClobber
```

9.  Run this to sysprep and "Generalize" the machine:

```
cd C:\windows\system32\sysprep
.\sysprep.exe /generalize
```

10.  Click the 'generalize' box and set the pulldown to "shutdown". Wait and give it a good ten minutes to fully shutdown.
11.  After the machine has been shut down, you can browse to it in the portal click it and create an image from it. Name it hc-training-workstation-DATE.  Example:  `hc-training-workstation-2019-01-11`
12. Use the image to spin up your workstations