#################################################
# Terraform Workshop Tests
#################################################

# https://hashicorp.github.io/workshops/azure/terraform/#31
control 'cd-desktop' do
  impact 1.0
  desc 'Change directory to the user desktop'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop;
    Get-Location'
  ) do
    its('stdout') { should match(/C:\\Users\\hashicorp\\Desktop/) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/workshops/azure/terraform/#38
control 'git-clone' do
  impact 1.0
  desc 'Clone the training repository'
  describe powershell(
    "cd C:\\Users\\hashicorp\\Desktop;
    Remove-Item -force -recurse -path C:\\Users\\hashicorp\\Desktop\\workshops
    git clone --single-branch --branch #{ENV['CIRCLE_BRANCH']} https://github.com/hashicorp/workshops.git
    # git clone https://github.com/hashicorp/workshops.git
    Get-ChildItem C:\\Users\\hashicorp\\Desktop\\workshops\\azure"
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/main.tf/) }
    its('stderr') { should match(//) }
  end
end

# Required! If this is not set Git for Windows will muck up your line endings.
# This causes the provisioning stage of Terraform to fail.
control 'verify-git-line-endings' do
  impact 1.0
  desc 'Make sure git line endings are set correctly.'
  describe file('C:\Users\hashicorp\.gitconfig') do
    it { should be_file }
    its('content') { should match(/autocrlf = false/) }
  end
end

# Clean up anything left from the previous run.
# We want a clean slate for the test environment.
control 'az-group-delete' do
  impact 1.0
  desc 'Clean up from any previous test run.'
  describe powershell(
    'az login --service-principal -u 91299f64-f951-4462-8e97-9efb1d215501 -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID;
    if ($(az group exists --name uat-tf-vault-lab-workshop).exit) {
      Write-Host "Deleting existing UAT environment.";
      az group delete -y --name uat-tf-vault-lab-workshop;
    } else {
      Write-Host "No UAT environment found. Proceeding."
    }'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Solutions/) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/workshops/azure/terraform/#45
control 'terraform-init' do
  impact 1.0
  desc 'Run terraform init.'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\workshops\azure;
    terraform init'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/1.30.1/) }
    its('stdout') { should match(/Terraform has been successfully initialized!/) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/workshops/azure/terraform/#46
control 'terraform-plan' do
  impact 1.0
  desc 'Run terraform plan.'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\workshops\azure;
    terraform plan -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/1 to add, 0 to change, 0 to destroy./) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/workshops/azure/terraform/#61
control 'terraform-apply' do
  impact 1.0
  desc 'Run terraform apply.'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\workshops\azure;
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/uat-tf-vault-lab-workshop/) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/workshops/azure/terraform/#64
control 'terraform-change-variable' do
  impact 1.0
  desc 'Re-run terraform apply with a different variable.'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\workshops\azure;
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab" -var "location=eastus"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/1 added, 0 changed, 1 destroyed/) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/workshops/azure/terraform/#65
control 'terraform-destroy' do
  impact 1.0
  desc 'Run terraform destroy'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\workshops\azure;
    terraform destroy -force -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Destroy complete! Resources: 1 destroyed./) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/workshops/azure/terraform/#66
control 'terraform-rebuild' do
  impact 1.0
  desc 'Run terraform apply again'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\workshops\azure;
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/1 added, 0 changed, 0 destroyed/) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/workshops/azure/terraform/#72
control 'terraform-build-vault-lab' do
  impact 1.0
  desc 'Build the rest of the Vault lab'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\workshops\azure;
    Copy-Item -Force "main.tf.completed" -Destination "main.tf"
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/10 added, 0 changed, 0 destroyed/) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/workshops/azure/terraform/#81
control 'terraform-refresh' do
  impact 1.0
  desc 'Run terraform refresh to show outputs'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\workshops\azure;
    Copy-Item -Force "outputs.tf.completed" -Destination "outputs.tf"
    terraform refresh -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Vault_Server_URL = http:\/\/uat-tf-vault-lab.centralus.cloudapp.azure.com/) }
    its('stdout') { should match(/MySQL_Server_FQDN = uat-tf-vault-lab-mysql-server.mysql.database.azure.com/)}
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/workshops/azure/terraform/#82
control 'terraform-output' do
  impact 1.0
  desc 'Run terraform output to show outputs'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\workshops\azure;
    terraform output'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Vault_Server_URL = http:\/\/uat-tf-vault-lab.centralus.cloudapp.azure.com/) }
    its('stdout') { should match(/MySQL_Server_FQDN = uat-tf-vault-lab-mysql-server.mysql.database.azure.com/)}
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/workshops/azure/terraform/#83
control 'terraform-output-singlevalue' do
  impact 1.0
  desc 'Run terraform output to show a single value'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\workshops\azure;
    terraform output Vault_Server_URL'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/http:\/\/uat-tf-vault-lab.centralus.cloudapp.azure.com/) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/workshops/azure/terraform/#86
control 'terraform-fmt' do
  impact 1.0
  desc 'Run terraform fmt to format code'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\workshops\azure;
    terraform fmt'
  ) do
    its('exit_status') { should eq 0 }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/workshops/azure/terraform/#96
# This step emulates a student adding 'cowsay Moooooo!' to their provisioner.
control 'terraform-taint-provisioner' do
  impact 1.0
  desc 'Run terraform taint and re-build virtual machine'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\workshops\azure;
    ((Get-Content -path C:\Users\hashicorp\Desktop\workshops\azure\main.tf -Raw) -replace "MYSQL_HOST=\`${var.prefix}-mysql-server /home/\`${var.admin_username}/setup.sh`"","MYSQL_HOST=`${var.prefix}-mysql-server /home/`${var.admin_username}/setup.sh`",`n      `"cowsay Moooooo!`"") | Set-Content -Path C:\Users\hashicorp\Desktop\workshops\azure\main.tf;
    terraform taint azurerm_virtual_machine.vault;
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Moooooo!/) }
    its('stderr') { should match(//) }
  end
end
