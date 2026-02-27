#################################################
# Terraform /Vault lab cleanup - AWS version
#################################################

control 'terraform-destroy' do
  impact 1.0
  desc 'Run terraform destroy'
  describe powershell(
    'cd C:\Users\hashicorp\Desktop\aws-tf-vault-workshop\aws;
    terraform destroy -force -var "prefix=uat-tf-vault-lab"'
  ) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Destroy complete! Resources: 15 destroyed./) }
    its('stderr') { should match(//) }
  end
end
