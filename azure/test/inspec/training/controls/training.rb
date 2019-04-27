# Walk through training exercises

control 'cd-desktop' do
  impact 1.0
  desc 'Change directory to the user desktop'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop;
    Get-Location'
  ) do
    its('stdout') { should match(/C:\\Users\\hashicorp\\Desktop/) }
  end
end

control 'run-setup-script' do
  impact 1.0
  desc 'Run the setup.ps1 script'
  describe powershell('powershell -ExecutionPolicy ByPass -File C:\Users\Public\Desktop\setup.ps1') do
    its('stdout') { should match(/You may proceed with the workshop./) }
  end
end

control 'git-clone' do
  impact 1.0
  desc 'Clone the training repository'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop;
    Remove-Item -force -recurse -path C:\Users\hashicorp\Desktop\se-terraform-vault-workshop
    git clone https://github.com/hashicorp/se-terraform-vault-workshop.git;
    Get-ChildItem C:\Users\hashicorp\Desktop\se-terraform-vault-workshop\azure'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/main.tf/) }
  end
end

control 'verify-git-line-endings' do
  impact 1.0
  desc 'Make sure git line endings are set correctly.'
  describe file('C:\Users\hashicorp\.gitconfig') do
    it { should be_file }
    its('content') { should match(/autocrlf = false/) }
  end
end

# Clean up anything left from the previous run
# Need some kind of 'az login' here.
# TODO:  See if the while loop is really needed.
control 'az-group-delete' do
  impact 1.0
  desc 'Clean up from any previous test run.'
  describe powershell(
    'az login --service-principal -u http://SE-Training-Workstation-Creds -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID;
    az group delete -y --name uat-tf-vault-lab-workshop;
    while($(az group exists --name uat-tf-vault-lab-workshop).exit) {
      Start-Sleep -s 5;
      Write-Host "Waiting for resource group to finish deleting..."
    }'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/PAYG/) }
    its('stderr') { should match(//) }
  end
end

control 'terraform-init' do
  impact 1.0
  desc 'Run terraform init.'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\se-terraform-vault-workshop\azure;
    terraform init'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/"azurerm" \(1.27.0\)/) }
    its('stdout') { should match(/Terraform has been successfully initialized!/) }
    its('stderr') { should match(//) }
  end
end

control 'terraform-plan' do
  impact 1.0
  desc 'Run terraform plan.'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\se-terraform-vault-workshop\azure;
    terraform plan -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/1 to add, 0 to change, 0 to destroy./) }
    its('stderr') { should match(//) }
  end
end

control 'terraform-apply' do
  impact 1.0
  desc 'Run terraform apply.'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\se-terraform-vault-workshop\azure;
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/name:     "" => "uat-tf-vault-lab-workshop"/) }
    its('stderr') { should match(//) }
  end
end

control 'terraform-change-variable' do
  impact 1.0
  desc 'Re-run terraform apply with a different variable.'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\se-terraform-vault-workshop\azure;
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab" -var "location=eastus"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/1 added, 0 changed, 1 destroyed/) }
    its('stderr') { should match(//) }
  end
end

control 'terraform-destroy' do
  impact 1.0
  desc 'Run terraform destroy'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\se-terraform-vault-workshop\azure;
    terraform destroy -force -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Destroy complete! Resources: 1 destroyed./) }
    its('stderr') { should match(//) }
  end
end

control 'terraform-rebuild' do
  impact 1.0
  desc 'Run terraform apply again'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\se-terraform-vault-workshop\azure;
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/1 added, 0 changed, 0 destroyed/) }
    its('stderr') { should match(//) }
  end
end

control 'terraform-build-vault-lab' do
  impact 1.0
  desc 'Build the rest of the Vault lab'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\se-terraform-vault-workshop\azure;
    Copy-Item -Force "main.tf.completed" -Destination "main.tf"
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/10 added, 0 changed, 0 destroyed/) }
    its('stderr') { should match(//) }
  end
end

control 'terraform-refresh' do
  impact 1.0
  desc 'Run terraform refresh to show outputs'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\se-terraform-vault-workshop\azure;
    Copy-Item -Force "outputs.tf.completed" -Destination "outputs.tf"
    terraform refresh -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Vault_Server_URL = http:\/\/uat-tf-vault-lab.centralus.cloudapp.azure.com/) }
    its('stdout') { should match(/MySQL_Server_FQDN = uat-tf-vault-lab-mysql-server.mysql.database.azure.com/)}
    its('stderr') { should match(//) }
  end
end

control 'terraform-output' do
  impact 1.0
  desc 'Run terraform output to show outputs'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\se-terraform-vault-workshop\azure;
    terraform output'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Vault_Server_URL = http:\/\/uat-tf-vault-lab.centralus.cloudapp.azure.com/) }
    its('stdout') { should match(/MySQL_Server_FQDN = uat-tf-vault-lab-mysql-server.mysql.database.azure.com/)}
    its('stderr') { should match(//) }
  end
end

control 'terraform-output-singlevalue' do
  impact 1.0
  desc 'Run terraform output to show a single value'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\se-terraform-vault-workshop\azure;
    terraform output Vault_Server_URL'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/http:\/\/uat-tf-vault-lab.centralus.cloudapp.azure.com/) }
    its('stderr') { should match(//) }
  end
end

control 'terraform-fmt' do
  impact 1.0
  desc 'Run terraform fmt to format code'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\se-terraform-vault-workshop\azure;
    terraform fmt'
  ) do
    its('exit_status') { should eq 0 }
    its('stderr') { should match(//) }
  end
end

# This step emulates a student adding 'cowsay Moooooo!' to their provisioner.
control 'terraform-taint-provisioner' do
  impact 1.0
  desc 'Run terraform taint and re-build virtual machine'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\se-terraform-vault-workshop\azure;
    ((Get-Content -path C:\Users\hashicorp\Desktop\se-terraform-vault-workshop\azure\main.tf -Raw) -replace "MYSQL_HOST=\`${var.prefix}-mysql-server /home/\`${var.admin_username}/setup.sh`"","MYSQL_HOST=`${var.prefix}-mysql-server /home/`${var.admin_username}/setup.sh`",`n      `"cowsay Moooooo!`"") | Set-Content -Path C:\Users\hashicorp\Desktop\se-terraform-vault-workshop\azure\main.tf;
    terraform taint azurerm_virtual_machine.vault;
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Moooooo!/) }
    its('stderr') { should match(//) }
  end
end

# TODO: Write tests for the Vault workshop

# control 'connect-to-vault' do
#   impact 1.0
#   desc 'Make a test connection to the Vault instance'
#   describe powershell(
#     '$VAULT_ADDR=https://'
#   )
