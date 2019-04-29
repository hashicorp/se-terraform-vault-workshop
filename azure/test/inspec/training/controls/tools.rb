# Makes sure all required tools are installed

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#42
control 'terraform-version' do
  impact 1.0
  desc 'Checks to see that Terraform is installed and working.'
  describe powershell('terraform --version') do
    its('stdout') { should match(/0.11.13/) }
  end
end

control 'vault-version' do
  impact 1.0
  desc 'Checks to see that Vault is installed and working.'
  describe powershell('vault --version') do
    its('stdout') { should match(/v1.1.1/) }
  end
end

control 'git-version' do
  impact 1.0
  desc 'Checks to see that Git is installed and working.'
  describe powershell('git --version') do
    its('stdout') { should match(/2.21.0.windows.1/) }
  end
end

control 'vsc-version' do
  impact 1.0
  desc 'Checks to see that Visual Studio Code is installed and working.'
  describe powershell('code --version') do
    its('stdout') { should match /1.31.1/ }
  end
end

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

# This must be in a separate control file from the training exercises. Otherwise
# it will be using credentials from the *previous* test run.
# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#32
control 'run-setup-script' do
  impact 1.0
  desc 'Run the setup.ps1 script'
  describe powershell('powershell -ExecutionPolicy ByPass -File C:\Users\Public\Desktop\setup.ps1') do
    its('stdout') { should match(/You may proceed with the workshop./) }
    its('stderr') { should match(//) }
  end
end
