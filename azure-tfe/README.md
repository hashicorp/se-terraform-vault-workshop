# Instructor Notes for TFE on Azure

In order to teach this workshop you'll need to do a few setup steps.

### Setup Steps

1. Create a training organization for your students.
2. Create a team in the organization called **students** and give it **Manage Workspaces** permissions.
3. Create a global sentinel policy called **block_allow_all_http**. The Sentinel code for this policy is stored in [policy/block_allow_all_http.sentinel](policy/block_allow_all_http.sentinel) file.
4. Set your policy enforcement mode to **advisory** for the beginning of training.
5. Spin up enough workstations for all your students. Instructions are included in the main [INSTRUCTOR_NOTES.md](../INSTRUCTOR_NOTES.md) file.


### Walkthrough

Go through the entire workshop and read all the speaker notes. Pretend you are a student taking the training for the first time. You can spin up a workstation and walk through the slides. Make sure you understand everything and know how things work.