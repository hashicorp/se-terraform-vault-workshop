#################################################
# Terraform Workshop Tests
#################################################

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#31
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

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#38
control 'git-clone' do
  impact 1.0
  desc 'Clone the training repository'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop;
    Remove-Item -force -recurse -path C:\Users\hashicorp\Desktop\aws-tf-vault-workshop;
    git clone https://github.com/hashicorp/se-terraform-vault-workshop.git aws-tf-vault-workshop;
    Get-ChildItem C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws'
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

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#45
control 'terraform-init' do
  impact 1.0
  desc 'Run terraform init.'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    terraform init'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/2.16.0/) }
    its('stdout') { should match(/Terraform has been successfully initialized!/) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#46
control 'terraform-plan' do
  impact 1.0
  desc 'Run terraform plan.'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    terraform plan -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/1 to add, 0 to change, 0 to destroy./) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#61
control 'terraform-apply' do
  impact 1.0
  desc 'Run terraform apply.'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/aws_vpc.workshop: Creation complete after/) }
    its('stderr') { should match(//) }
  end
end

# This may not be necessary
# # https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#64
# control 'terraform-change-variable' do
#   impact 1.0
#   desc 'Re-run terraform apply with a different variable.'
#   describe powershell(
#     'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
#     terraform apply -auto-approve -var "prefix=uat-tf-vault-lab" -var "location=eastus"'
#   ) do
#     its('exit_status') { should eq 0 }
#     its('stdout') { should match(/1 added, 0 changed, 1 destroyed/) }
#     its('stderr') { should match(//) }
#   end
# end

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#65
control 'terraform-destroy' do
  impact 1.0
  desc 'Run terraform destroy'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    terraform destroy -force -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Destroy complete! Resources: 1 destroyed./) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#66
control 'terraform-rebuild' do
  impact 1.0
  desc 'Run terraform apply again'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/1 added, 0 changed, 0 destroyed/) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#72
control 'terraform-build-vault-lab' do
  impact 1.0
  desc 'Build the rest of the Vault lab'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    Copy-Item -Force "main.tf.completed" -Destination "main.tf"
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/10 added, 0 changed, 0 destroyed/) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#81
control 'terraform-refresh' do
  impact 1.0
  desc 'Run terraform refresh to show outputs'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    Copy-Item -Force "outputs.tf.completed" -Destination "outputs.tf"
    terraform refresh -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Vault_Server_URL = http:\/\/uat-tf-vault-lab.centralus.cloudapp.azure.com/) }
    its('stdout') { should match(/MySQL_Server_FQDN = uat-tf-vault-lab-mysql-server.mysql.database.azure.com/)}
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#82
control 'terraform-output' do
  impact 1.0
  desc 'Run terraform output to show outputs'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    terraform output'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Vault_Server_URL = http:\/\/uat-tf-vault-lab.centralus.cloudapp.azure.com/) }
    its('stdout') { should match(/MySQL_Server_FQDN = uat-tf-vault-lab-mysql-server.mysql.database.azure.com/)}
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#83
control 'terraform-output-singlevalue' do
  impact 1.0
  desc 'Run terraform output to show a single value'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    terraform output Vault_Server_URL'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/http:\/\/uat-tf-vault-lab.centralus.cloudapp.azure.com/) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#86
control 'terraform-fmt' do
  impact 1.0
  desc 'Run terraform fmt to format code'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    terraform fmt'
  ) do
    its('exit_status') { should eq 0 }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#96
# This step emulates a student adding 'cowsay Moooooo!' to their provisioner.
control 'terraform-taint-provisioner' do
  impact 1.0
  desc 'Run terraform taint and re-build virtual machine'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    ((Get-Content -path C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws\main.tf -Raw) -replace "MYSQL_HOST=\`${var.prefix}-mysql-server /home/\`${var.admin_username}/setup.sh`"","MYSQL_HOST=`${var.prefix}-mysql-server /home/`${var.admin_username}/setup.sh`",`n      `"cowsay Moooooo!`"") | Set-Content -Path C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws\main.tf;
    terraform taint azurerm_virtual_machine.vault;
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Moooooo!/) }
    its('stderr') { should match(//) }
  end
end
