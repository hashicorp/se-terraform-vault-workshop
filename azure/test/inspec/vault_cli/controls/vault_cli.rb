#################################################
# Vault CLI Tests
#################################################

# Chapter 3 - Install Vault autocomplete
control 'install-autocomplete' do
  impact 1.0
  desc 'Install Vault autocomplete in our shell'
  describe powershell(
    '$HOSTKEY=(ssh-keyscan -H uat-tf-vault-lab.centralus.cloudapp.azure.com | Select-String -Pattern "ed25519" | Select -ExpandProperty line);
    plink.exe -ssh hashicorp@uat-tf-vault-lab.centralus.cloudapp.azure.com -pw Password123! -hostkey $HOSTKEY "vault -autocomplete-install; source ~/.bashrc"'
   ) do
    its('stdout') { should match(//) }
  end
end

# Chapter 3 - Test the vault kv list command
control 'test-vault-kv-list-cli' do
  impact 1.0
  desc 'Test the vault kv list command'
  describe powershell(
    '$HOSTKEY=(ssh-keyscan -H uat-tf-vault-lab.centralus.cloudapp.azure.com | Select-String -Pattern "ed25519" | Select -ExpandProperty line);
    plink.exe -ssh hashicorp@uat-tf-vault-lab.centralus.cloudapp.azure.com -pw Password123! -hostkey $HOSTKEY "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root vault kv list kv/data/department/team"'
  ) do
    its('stdout') { should match(/mysecret/) }
  end
end

# Lab exercise 4a - create some policies
control 'create-vault-policies' do
  impact 1.0
  desc 'Create some vault policies'
  describe powershell(
    '$HOSTKEY=(ssh-keyscan -H uat-tf-vault-lab.centralus.cloudapp.azure.com | Select-String -Pattern "ed25519" | Select -ExpandProperty line);
    plink.exe -ssh hashicorp@uat-tf-vault-lab.centralus.cloudapp.azure.com -pw Password123! -hostkey $HOSTKEY "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root MYSQL_HOST=uat-tf-vault-lab-mysql-server ~/test/create_policies.sh"'
  ) do
    its('stdout') { should match(/Script complete./) }
  end
end
  
# Lab exercise 5a - Bob and Sally Exercise 1
control 'bob-and-sally-exercise-1' do
  impact 1.0
  desc 'Create user accounts for Bob and Sally'
  describe powershell(
    '$HOSTKEY=(ssh-keyscan -H uat-tf-vault-lab.centralus.cloudapp.azure.com | Select-String -Pattern "ed25519" | Select -ExpandProperty line);
    plink.exe -ssh hashicorp@uat-tf-vault-lab.centralus.cloudapp.azure.com -pw Password123! -hostkey $HOSTKEY "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root MYSQL_HOST=uat-tf-vault-lab-mysql-server ~/test/bob_and_sally.sh"'
  ) do
    its('stdout') { should match(/Script complete./) }
  end
end
  
# Lab exercise 5a - Bob and Sally Exercise 2
control 'bob-and-sally-exercise-2' do
  impact 1.0
  desc 'Grant Sally read access to secret/'
  describe powershell(
    '$HOSTKEY=(ssh-keyscan -H uat-tf-vault-lab.centralus.cloudapp.azure.com | Select-String -Pattern "ed25519" | Select -ExpandProperty line);
    plink.exe -ssh hashicorp@uat-tf-vault-lab.centralus.cloudapp.azure.com -pw Password123! -hostkey $HOSTKEY "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root MYSQL_HOST=uat-tf-vault-lab-mysql-server ~/test/recreate_sally.sh"'
  ) do
    its('stdout') { should match(/Script complete./) }
  end
end

# Chapter 7 - database setup script
control 'database-setup-script' do
  impact 1.0
  desc 'Run the database setup script.'
  describe powershell(
    '$HOSTKEY=(ssh-keyscan -H uat-tf-vault-lab.centralus.cloudapp.azure.com | Select-String -Pattern "ed25519" | Select -ExpandProperty line);
    plink.exe -ssh hashicorp@uat-tf-vault-lab.centralus.cloudapp.azure.com -pw Password123! -hostkey $HOSTKEY "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root MYSQL_HOST=uat-tf-vault-lab-mysql-server ~/database_setup.sh"'
  ) do
    its('stdout') { should match(/Enabled the database secrets engine at: lob_a\/workshop\/database\//) }
    its('stdout') { should match(/Data written to: lob_a\/workshop\/database\/roles\/workshop-app-long/) }
    its('stdout') { should match(/Data written to: lob_a\/workshop\/database\/roles\/workshop-app/) }
    its('stdout') { should match(/Script complete./) }
  end
end
  
# Lab exercise 7a - Dynamic Creds - CLI
control 'get-dynamic-creds-cli' do
  impact 1.0
  desc 'Fetch dynamic database credentials on the command line'
  describe powershell(
    '$HOSTKEY=(ssh-keyscan -H uat-tf-vault-lab.centralus.cloudapp.azure.com | Select-String -Pattern "ed25519" | Select -ExpandProperty line);
    plink.exe -ssh hashicorp@uat-tf-vault-lab.centralus.cloudapp.azure.com -pw Password123! -hostkey $HOSTKEY "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root vault read lob_a/workshop/database/creds/workshop-app"'
  ) do
    its('stdout') { should match(/v-token-workshop-a/) }
  end
end

# Chapter 7 - Test MySQL login
control 'test-mysql-login' do
  impact 1.0
  desc 'Attempt to log onto the mysql server'
  describe powershell(
    '$HOSTKEY=(ssh-keyscan -H uat-tf-vault-lab.centralus.cloudapp.azure.com | Select-String -Pattern "ed25519" | Select -ExpandProperty line);
    plink.exe -ssh hashicorp@uat-tf-vault-lab.centralus.cloudapp.azure.com -pw Password123! -hostkey $HOSTKEY "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root ./mysql_login.sh"'
  ) do
    its('stdout') { should match(/Script complete./) }
  end
end

# Chapter 8 - database setup script
control 'transit-setup-script' do
  impact 1.0
  desc 'Run the transit setup script.'
  describe powershell(
    '$HOSTKEY=(ssh-keyscan -H uat-tf-vault-lab.centralus.cloudapp.azure.com | Select-String -Pattern "ed25519" | Select -ExpandProperty line);
    plink.exe -ssh hashicorp@uat-tf-vault-lab.centralus.cloudapp.azure.com -pw Password123! -hostkey $HOSTKEY "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root MYSQL_HOST=uat-tf-vault-lab-mysql-server ~/transit_setup.sh"'
  ) do
    its('stdout') { should match(/Script complete./) }
  end
end

# Chapter 8 - setup Python app
control 'transit-setup-script' do
  impact 1.0
  desc 'Run the transit setup script.'
  describe powershell(
    '$HOSTKEY=(ssh-keyscan -H uat-tf-vault-lab.centralus.cloudapp.azure.com | Select-String -Pattern "ed25519" | Select -ExpandProperty line);
    plink.exe -ssh hashicorp@uat-tf-vault-lab.centralus.cloudapp.azure.com -pw Password123! -hostkey $HOSTKEY "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root MYSQL_HOST=uat-tf-vault-lab-mysql-server ~/transit_setup.sh"'
  ) do
    its('stdout') { should match(/Script complete./) }
  end
end