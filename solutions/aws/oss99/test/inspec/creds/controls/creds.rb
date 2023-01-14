#################################################
# AWS Credentials Tests
#################################################

# See that the local system environment variables are formed correctly.
# These might be expired or invalid so we test them in the next step.
control 'check-aws-api-credentials' do
  impact 1.0
  desc 'Checks to see that valid-looking AWS credentials are set as environment variables.'
  describe powershell('Get-ChildItem Env:AWS_ACCESS_KEY_ID | select -ExpandProperty Value') do
    its('stdout') { should match(%r{(?<![A-Z0-9])[A-Z0-9]{20}(?![A-Z0-9])}) }
  end
  describe powershell('Get-ChildItem Env:AWS_SECRET_ACCESS_KEY | select -ExpandProperty Value') do
    its('stdout') { should match(%r{(?<![A-Za-z0-9/+=])[A-Za-z0-9/+=]{40}(?![A-Za-z0-9/+=])}) }
  end
end

# TODO: verify the aws credentials, fix the pseudo code below
# Probably have to install aws command line in our container...

# control 'aws-account-login' do
#   impact 1.0
#   desc 'Make sure our AWS credentials are valid.'
#   describe powershell(
#     'aws ec2 do-something-here ${env:AWS_ACCESS_KEY_ID} ${env:AWS_SECRET_ACCESS_KEY'
#   ) do
#     its('exit_status') { should eq 0 }
#     its('stdout') { should match(/Whatever/) }
#     its('stderr') { should match(//) }
#   end
# end
