#################################################
# Azure Credentials Tests
#################################################

# See that the local system environment variables are formed correctly.
# These might be expired or invalid so we test them in the next step.
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

# Run an `az account login` to make sure the creds are still valid.
# It is also possible that these credentials are not valid *yet*, there
# can be a delay between when they are issued, and when you can actually
# use them. Eventualy consistency ftw.
control 'az-account-login' do
  impact 1.0
  desc 'Make sure our AZ credentials are valid.'
  describe powershell(
    'az login --service-principal -u 91299f64-f951-4462-8e97-9efb1d215501 -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID --allow-no-subscription'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Solutions/) }
    its('stderr') { should match(//) }
  end
end
