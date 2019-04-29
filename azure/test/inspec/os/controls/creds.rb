# Check that we have valid Azure credentials

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#32
control 'run-setup-script' do
  impact 1.0
  desc 'Run the setup.ps1 script'
  describe powershell('powershell -ExecutionPolicy ByPass -File C:\Users\Public\Desktop\setup.ps1') do
    its('stdout') { should match(/You may proceed with the workshop./) }
    its('stderr') { should match(//) }
  end
end

control 'check-azure-api-credentials' do
  impact 1.0
  desc 'Checks to see that valid-looking Azure credentials are set as environment variables.'
  describe powershell('Get-ChildItem Env:ARM_CLIENT_ID | select -ExpandProperty Value') do
    its('stdout') { should match(/[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}/) }
  end
  describe powershell('Get-ChildItem Env:ARM_TENANT_ID | select -ExpandProperty Value') do
    its('stdout') { should match(/[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}/) }
  end
  describe powershell('Get-ChildItem Env:ARM_SUBSCRIPTION_ID | select -ExpandProperty Value') do
    its('stdout') { should match(/[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}/) }
  end
  describe powershell('Get-ChildItem Env:ARM_CLIENT_SECRET | select -ExpandProperty Value') do
    its('stdout') { should match(/[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}/) }
  end
end
