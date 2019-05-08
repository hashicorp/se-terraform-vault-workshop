#################################################
# Vault DB Tests
#################################################

# Lab exercise 7a - Dynamic Creds - CLI
control 'vault-fetch-dbcreds-cli' do
  impact 1.0
  desc 'Fetch dynamic creds using the CLI'
  describe powershell(
    '$HOSTKEY=(ssh-keyscan -H uat-tf-vault-lab.centralus.cloudapp.azure.com | Select-String -Pattern "ed25519" | Select -ExpandProperty line);
    plink.exe -ssh hashicorp@uat-tf-vault-lab.centralus.cloudapp.azure.com -pw Password123! -hostkey $HOSTKEY "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root MYSQL_HOST=uat-tf-vault-lab-mysql-server vault read lob_a/workshop/database/creds/workshop-app"'
  ) do
    its('stdout') { should match(/v-token-workshop-a/) }
  end
end
  