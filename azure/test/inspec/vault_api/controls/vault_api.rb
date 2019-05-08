#################################################
# Vault API Tests
#################################################

# See if the API is responding
control 'vault-api-status' do
  impact 1.0
  desc 'Checks the Vault API status endpoint.'
  describe http('http://uat-tf-vault-lab.centralus.cloudapp.azure.com:8200/v1/sys/health') do
    its('status') { should cmp 200 }
    its('body') { should match /"initialized":true/ }
    its('body') { should match /"sealed":false/ }
    its('body') { should match /"version":"1.1.1"/ }
  end
end

# Chapter 3 - Test authentication with root token
control 'vault-read-mounts' do
  impact 1.0
  desc 'Make an authenticated API call with the root token.'
  describe http('http://uat-tf-vault-lab.centralus.cloudapp.azure.com:8200/v1/sys/mounts', headers: {'X-Vault-Token' => 'root'}) do
    its('status') { should cmp 200 }
  end
end
  
# Chapter 3 - Interacting with Vault
control 'vault-mount-kv' do
  impact 1.0
  desc 'Mount key/value secrets engine'
  describe http('http://uat-tf-vault-lab.centralus.cloudapp.azure.com:8200/v1/sys/mounts/kv', 
    headers: {'X-Vault-Token' => 'root', 'Content-Type' => 'application/json'},
    method: 'POST',
    data: '{"type": "kv", "config": { "version": "2" }}'
  ) do
    its('status') { should be_in [200,204] }
  end
end
  
# Lab exercise 3a - Create a secret
control 'vault-create-kv-secret' do
  impact 1.0
  desc 'Create a key/value secret'
  describe http('http://uat-tf-vault-lab.centralus.cloudapp.azure.com:8200/v1/kv/data/department/team/mysecret', 
    headers: {'X-Vault-Token' => 'root', 'Content-Type' => 'application/json'},
    method: 'POST',
    data: '{ "rootpass": "supersecret" }'
  ) do
    its('status') { should be_in [200,204] }
  end
end
  
# Lab exercise 3b - Retreive a secret
control 'vault-read-kv-secret' do
  impact 1.0
  desc 'Read a key/value secret'
  describe http('http://uat-tf-vault-lab.centralus.cloudapp.azure.com:8200/v1/kv/data/department/team/mysecret', 
    headers: {'X-Vault-Token' => 'root', 'Content-Type' => 'application/json'},
    method: 'GET'
  ) do
    its('status') { should be_in [200,204] }
    its('body') { should match 'rootpass' }
    its('body') { should match 'supersecret' }
  end
end
  
# Lab exercise 3c - make an API call
control 'vault-test-api-call' do
  impact 1.0
  desc 'Get token info from the API'
  describe http('http://uat-tf-vault-lab.centralus.cloudapp.azure.com:8200/v1/auth/token/lookup-self', 
    headers: {'X-Vault-Token' => 'root', 'Content-Type' => 'application/json'},
    method: 'GET'
  ) do
    its('status') { should be_in [200] }
    its('body') { should match 'foo' }
  end
end
    
# Lab exercise 7a - Dynamic Creds - API
control 'vault-test-api-call' do
  impact 1.0
  desc 'Fetch dynamic creds using the API'
  describe http('http://uat-tf-vault-lab.centralus.cloudapp.azure.com:8200/v1/lob_a/workshop/database/creds/workshop-app-long', 
    headers: {'X-Vault-Token' => 'root', 'Content-Type' => 'application/json'},
    method: 'GET'
  ) do
    its('status') { should be_in [200] }
    its('body') { should match 'foo' }
  end
end
