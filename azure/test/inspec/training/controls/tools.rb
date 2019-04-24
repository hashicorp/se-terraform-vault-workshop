# Makes sure all required tools are installed

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
