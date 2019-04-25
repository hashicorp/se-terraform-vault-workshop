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
    rm -r -Force azure-terraform-vault-workshop;
    git clone https://github.com/scarolan/azure-terraform-vault-workshop;
    Get-ChildItem C:\Users\hashicorp\Desktop\azure-terraform-vault-workshop'
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

control 'terraform-init' do
  impact 1.0
  desc 'Run terraform init.'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\azure-terraform-vault-workshop;
    terraform init'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/provider.azurerm: version = "~> 1.25"/) }
    its('stdout') { should match(/Terraform has been successfully initialized!/) }
  end
end

control 'terraform-plan' do
  impact 1.0
  desc 'Run terraform plan.'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\azure-terraform-vault-workshop;
    terraform plan -var "prefix=inspectest"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/1 to add, 0 to change, 0 to destroy./) }
  end
end

control 'terraform-destroy' do
  impact 1.0
  desc 'Run terraform destroy.'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\azure-terraform-vault-workshop;
    terraform destroy -force -var "prefix=uat-tf-vault"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Destroy complete!/) }
  end
end

control 'terraform-apply' do
  impact 1.0
  desc 'Run terraform apply.'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\azure-terraform-vault-workshop;
    terraform apply -auto-approve -var "prefix=uat-tf-vault"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/name:     "" => "uat-tf-vault-workshop"/) }
  end
end
