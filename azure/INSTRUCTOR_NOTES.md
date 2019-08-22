# Instructor Notes for TFE on Azure

In order to teach this workshop you'll need to do a few setup steps.

### Setup Steps

1. Create a training organization for your students.
2. Create a team in the organization called **students** and give it **Manage Workspaces** permissions.
3. Create a global sentinel policy called **block_allow_all_http**. The code is stored in the **`azure/tfe/policy`** directory.
4. Set your policy enforcement mode to **advisory** for the beginning of training.
5. Spin up enough workstations for all your students. Instructions are included in the main [INSTRUCTOR_NOTES.md](../INSTRUCTOR_NOTES.md) file.