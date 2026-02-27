#################################################
# Vault DB Tests
#################################################

# Lab exercise 7a - Dynamic Creds - API
control 'vault-test-api-call' do
  impact 1.0
  desc 'Fetch dynamic creds using the API'
  describe http('http://uat-tf-vault-lab.centralus.cloudapp.azure.com:8200/v1/lob_a/workshop/database/creds/workshop-app-long', 
    headers: {'X-Vault-Token' => 'root', 'Content-Type' => 'application/json'},
    method: 'GET'
  ) do
    its('status') { should be_in [200] }
    its('body') { should match 'v-token-workshop-a' }
  end
end
  