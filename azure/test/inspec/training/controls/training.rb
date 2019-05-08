#################################################
# Terraform Workshop Tests
#################################################

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#31
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

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#38
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
    'az login --service-principal -u http://SE-Training-Workstation-Creds -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID;
    if ($(az group exists --name uat-tf-vault-lab-workshop).exit) {
      Write-Host "Deleting existing UAT environment.";
      az group delete -y --name uat-tf-vault-lab-workshop;
    } else {
      Write-Host "No UAT environment found. Proceeding."
    }'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/PAYG/) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#45
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

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#46
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

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#61
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

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#64
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

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#65
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

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#66
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

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#72
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

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#81
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

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#82
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

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#83
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

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#86
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

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#96
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

#################################################
# Vault Workshop Tests
#################################################

# See if the API is responding
control 'vault-api-status' do
  impact 1.0
  desc 'Checks the Vault API status endpoint.'
  describe http('http://uat-tf-vault-lab.centralus.cloudapp.azure.com:8200/v1/sys/health') do
    its('status') { should cmp 200 }
    its('body') { should match /"initialized":true/ }
    its('body') { should match /"sealed":false/ }
    its('body') { should match /"version":"1.1.0"/ }
  end
end

# Chapter 3 - Test authentication with root token
control 'vault-read-mounts' do
  impact 1.0
  desc 'Make an authenticated API call with the root token.'
  describe http('http://uat-tf-vault-lab.centralus.cloudapp.azure.com:8200/v1/sys/mounts', headers: {'X-Vault-Token' => 'root'}) do
    its('status') { should cmp 200 }
  end
end

# Chapter 3 - Interacting with Vault
control 'vault-mount-kv' do
  impact 1.0
  desc 'Mount key/value secrets engine'
  describe http('http://uat-tf-vault-lab.centralus.cloudapp.azure.com:8200/v1/sys/mounts/kv', 
    headers: {'X-Vault-Token' => 'root', 'Content-Type' => 'application/json'},
    method: 'POST',
    data: '{"type": "kv", "config": { "version": "2" }}'
  ) do
    its('status') { should be_in [200,204] }
  end
end

# Lab exercise 3a - Create a secret
control 'vault-create-kv-secret' do
  impact 1.0
  desc 'Create a key/value secret'
  describe http('http://uat-tf-vault-lab.centralus.cloudapp.azure.com:8200/v1/kv/data/department/team/mysecret', 
    headers: {'X-Vault-Token' => 'root', 'Content-Type' => 'application/json'},
    method: 'POST',
    data: '{ "rootpass": "supersecret" }'
  ) do
    its('status') { should be_in [200,204] }
  end
end

# Lab exercise 3b - Retreive a secret
control 'vault-read-kv-secret' do
  impact 1.0
  desc 'Read a key/value secret'
  describe http('http://uat-tf-vault-lab.centralus.cloudapp.azure.com:8200/v1/kv/data/department/team/mysecret', 
    headers: {'X-Vault-Token' => 'root', 'Content-Type' => 'application/json'},
    method: 'GET'
  ) do
    its('status') { should be_in [200,204] }
    its('body') { should match 'rootpass' }
    its('body') { should match 'supersecret' }
  end
end

# Lab exercise 3c - make an API call
control 'vault-test-api-call' do
  impact 1.0
  desc 'Get token info from the API'
  describe http('http://uat-tf-vault-lab.centralus.cloudapp.azure.com:8200/v1/auth/token/lookup-self', 
    headers: {'X-Vault-Token' => 'root', 'Content-Type' => 'application/json'},
    method: 'GET'
  ) do
    its('status') { should be_in [200] }
    its('body') { should match 'foo' }
  end
end

# Verifies that we can connect via SSH and run our database_setup.sh script
# Since we're not using SSH keys we have to do this in two steps, first 
# we find and store the server host public key fingerprint, then we use 
# the plink command to start an SSH session and run our script with the 
# appropriate variables.
control 'database-setup-script' do
  impact 1.0
  desc 'Run the database setup script.'
  describe powershell(
    '$HOSTKEY=(ssh-keyscan -H uat-tf-vault-lab.centralus.cloudapp.azure.com | Select-String -Pattern "ed25519" | Select -ExpandProperty line);
    plink.exe -ssh hashicorp@uat-tf-vault-lab.centralus.cloudapp.azure.com -pw Password123! -hostkey $HOSTKEY "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root MYSQL_HOST=uat-tf-vault-lab-mysql-server ~/database_setup.sh"'
  ) do
    its('stdout') { should match(/Enabled the database secrets engine at: lob_a\/workshop\/database\//) }
    its('stdout') { should match(/Data written to: lob_a\/workshop\/database\/roles\/workshop-app-long/) }
    its('stdout') { should match(/Data written to: lob_a\/workshop\/database\/roles\/workshop-app/) }
    its('stdout') { should match(/Script complete./) }
  end
end
