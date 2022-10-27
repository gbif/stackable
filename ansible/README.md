# GBIF Ansible project for Kubernetes
**NOTE:** This project is still WIP
## Description
Ansible project for configuring the required software running a Kuberenetes node on a server. The Ansible project uses the [Alternative Directory Layout](https://docs.ansible.com/ansible/2.8/user_guide/playbooks_best_practices.html#alternative-directory-layout) described in the Ansible's best practices. Short description of the local layout:

```
inventories             <--- Contains the different server tiers env variables
    develop             <--- Currently the Kubernetes cluster used for testing the setup
    staging             <--- Designated for UAT
    production
roles                   <--- Used to define the different roles
    common              <--- Contains the common components for the two different types of nodes
controllernodes.yaml    <--- Playbook for controller nodes
workernodes.yaml        <--- Playbook for the worker nodes
site.yaml               <--- Main playbook to start the ansible project with
```

To run the full playbook use, use the following command:
``` bash
ansible-playbook -c SSH -i ./inventories/<env> -u <personal_ssh_user> site.yaml
```

By changes **site.yaml** to e.g. **controllernodes.yaml** you limit which servers that gets updated.

For linting the playbooks use the command:

``` bash
ansible-lint ./site.yaml ./roles/<specific_role_to_test>
```
## Requirements
To be able to run the playbooks, **an ssh user is required** for the servers Ansible should run towards. With a ssh user configured, the Ansible runner needs the following tools installed:

1. Python version >= 3.10.7
2. Ansible version >= 2.13.4

Optionally you can install the lint module for enabling linting:

1. Anisble-lint >= 6.7.0 (Installed with PIP3)

## TODOs
This Ansible project is still **under construction** so here is a list of tasks that still needs to be implemented for it to completed:

- [] Disable the swap partitions on the server (Required for Kubernetes)
- [] Implement automatic execution of kubeadm for controller creation
- [] Implement automatic joining the workers together with the controllers
- [] Create inventory for staging
- [] Create inventory for production