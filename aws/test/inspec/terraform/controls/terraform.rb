#################################################
# Terraform Workshop Tests - AWS version
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

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#60
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

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#62
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

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#69
control 'terraform-build-vault-lab' do
  impact 1.0
  desc 'Build the rest of the Vault lab'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    Copy-Item -Force "main.tf.completed" -Destination "main.tf"
    terraform init
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/15 added, 0 changed, 0 destroyed/) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#78
control 'terraform-refresh' do
  impact 1.0
  desc 'Run terraform refresh to show outputs'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    Copy-Item -Force "outputs.tf.completed" -Destination "outputs.tf"
    terraform refresh -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Vault_Server_URL = http:\/\//) }
    its('stdout') { should match(/MySQL_Server_FQDN = uat-tf-vault-lab-tf-workshop-rds/)}
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#79
control 'terraform-output' do
  impact 1.0
  desc 'Run terraform output to show outputs'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    terraform output'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Vault_Server_URL/) }
    its('stdout') { should match(/MySQL_Server_FQDN/)}
    its('stderr') { should match(//) }
  end
end

control 'terraform-output-singlevalue' do
  impact 1.0
  desc 'Run terraform output to show a single value'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    terraform output Vault_Server_URL'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/http:\/\//) }
    its('stderr') { should match(//) }
  end
end

# https://hashicorp.github.io/se-terraform-vault-workshop/aws/terraform/#83
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

control 'terraform-taint-provisioner' do
  impact 1.0
  desc 'Run terraform taint and re-build virtual machine'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    terraform taint aws_instance.vault-server;
    terraform apply -auto-approve -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/1 added, 0 changed, 1 destroyed/) }
    its('stderr') { should match(//) }
  end
end

# Final destroy to clean up
# This should be moved to the end of the vault tests when they are built
control 'terraform-destroy' do
  impact 1.0
  desc 'Run terraform destroy'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    terraform destroy -force -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Destroy complete! Resources: 15 destroyed./) }
    its('stderr') { should match(//) }
  end
end