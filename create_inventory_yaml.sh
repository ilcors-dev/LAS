#!/bin/bash

## Fetches the ssh-config from vagrant and creates an inventory.yaml file with the information.
## The inventory.yaml file is used by ansible to connect to the virtual machines typically used to provision them.
## Example:
##  ansible-playbook -i inventory.yaml playbook.yaml

template=$(
  cat <<'END_HEREDOC'
all:
  children:
END_HEREDOC
)

function noDotVagrantError() {
  echo "It appears that no vagrant machine has been created in the current folder."
  echo "Run 'vagrant up' to start your virtual machines."
  exit 1
}

function vmRunningError() {
  echo "It appears that some of virtual machine is stopped, every vm must be running to continue."
  echo "Run 'vagrant up' to start your virtual machines."
  exit 2
}

! test -d .vagrant && noDotVagrantError

status=$(vagrant status | grep 'poweroff' | wc -l)

test "$status" -gt 0 && vmRunningError

sshconf=$(vagrant ssh-config)

cat ssh.conf | awk -v RS= '{print > ("vm-" NR ".temp")}'

echo "$template" >inventory.yaml

group="0"

while read file; do
  # store local entry template
  entry=$(
    cat <<'END_HEREDOC'
    group{{group}}:
      hosts:
        {{hostname}}: 
          ansible_host: 127.0.0.1 
          ansible_port: {{port}}
          ansible_hostname: {{hostname}}
          ansible_user: vagrant
          ansible_ssh_private_key_file: .vagrant/machines/{{hostname}}/virtualbox/private_key
END_HEREDOC
  )

  content=$(cat $file)

  # get port
  port=$(echo "$content" | awk -F 'Port ' '{print $2}' | xargs)

  # get hostname
  hostname=$(echo "$content" | awk -F 'Host ' '{print $2}' | xargs)

  # replace variables in entry template
  entry=$(echo "$entry" | sed "s/{{group}}/$group/g")
  entry=$(echo "$entry" | sed "s/{{port}}/$port/g")
  entry=$(echo "$entry" | sed "s/{{hostname}}/$hostname/g")

  # append entry to inventory.yaml
  echo "$entry" >>inventory.yaml

  group=$((group + 1))

  # clean ssh key from known_hosts
  ssh-keygen -f /home/ilcors/.ssh/known_hosts -R [127.0.0.1]:"$port"
done <<<$(ls vm-*.temp)

# remove temporary files
rm vm-*.temp
