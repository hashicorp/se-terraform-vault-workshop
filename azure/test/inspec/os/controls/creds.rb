# Check that we have valid Azure credentials

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
