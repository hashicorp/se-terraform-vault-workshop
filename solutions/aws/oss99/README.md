# aws-terraform-vault-workshop
This repo contains Terraform code for standing up a HashiCorp Vault training lab on Amazon Web Services. You can use it for a half-day Terraform workshop, a half-day Vault workshop or combined day-long workshop covering both. To set up and run either or both workshops, simply follow the instructions below.

### Lab Setup
1. Clone or download the code from here: https://github.com/hashicorp/workshops
1. Open a terminal and cd into the workshops/aws directory
1. Copy the settings in `terraform.tfvars.example` into a `terraform.tfvars` file. Set the prefix variable to your name. This is the only required setting. You can also change the location variable to the AWS region nearest you.
1. Uncomment the code in main.tf (or simply copy over it with main.tf.completed)
1. Uncomment the code in outputs.tf (or copy from outputs.tf.completed)
1. Run `terraform plan` and then `terraform apply`
1. Go get some coffee. It takes roughly 4-5 minutes to provision this environment on AWS.
1. When the setup is done, follow the steps listed in the Terraform output.

### Note for Instructors:
If you're teaching this workshop to a class, head on over to the [Instructor Notes](../INSTRUCTOR_NOTES.md) page.
