# Create an Ubuntu EC2 instance for dev in AWS 

## Prerequisites 

### Create the following env-vars in your environment
- `GIT_NAME`: User name on git used for commits.
- `GIT_EMAIL`: Email associated with git commits.
- `GIT_SIGNING_KEY`: Signing Key to use with git commits. GitHub lets you use [SSH *Public Keys*](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification#ssh-commit-signature-verification). So something like `export GIT_SIGNING_KEY=$(cat ~/.ssh/id_rsa.pub)` can be used.
- `GITHUB_USERNAME`: Github username.
- `GITHUB_TOKEN`: Github token.
- `DOCKER_USERNAME`: Docker user.
- `DOCKER_PASSWORD`: Docker password.
### Configure SSH
Add the following to `~/.ssh/config` based on the above env-vars, add/remove as necessary.
```
Host ec2-*us-west-2.compute.amazonaws.com
  ForwardAgent yes
  SendEnv GIT_NAME
  SendEnv GIT_EMAIL
  SendEnv GIT_SIGNING_KEY
  SendEnv GITHUB_USERNAME
  SendEnv GITHUB_TOKEN
  SendEnv DOCKER_USERNAME
  SendEnv DOCKER_PASSWORD
```
- Terraform v0.13.7. Use [tfenv](https://github.com/tfutils/tfenv) for installation. If you're working with an M1 Mac laptop, try installing Terraform v1.0.11.

## Creation
Edit the `terraform.tfvars` file and adjust owner, instance_type and iam_instance_profile values.
Make sure to refresh AWS credentials before running the following command.

```shell
make create
```

The command will output the public dns of the machine as well as an SSH connection string. It is recommended to use tmux to prevent commands from failing due to connection.

### Set up the repo
Adjust the `TARGET_REPO` variable in the [Makefile](Makefile) to set the local path the target repository.
The local changes will be synchronized to the remote dev instance automatically.

To copy the repo to the remote instance and start the watcher:
```shell
make sync-repo
```

### To connect with SSH
```shell
make connect
```

To install Kommander and Insights backend, run:
```
./boostrap.sh
```

### Open Kommander dashboard
it is possible to access Kommander Dashboard from the local browser via SSH tunnel and SOCKS proxy. 
Configure SOCKS proxy in the network settings (the default port is 1337) and then run the following target to obtain 
the credentials and open Kommander UI:

```shell
make dashboard
```

## Destroy and cleanup
```shell
make destroy clean
```
