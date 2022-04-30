## install ansible

```
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

## install packages
```
ansible-playbook install-*.yaml --ask-become-pass
```

## install docker
```
ansible-galaxy install geerlingguy.docker
ansible-playbook install-docker.yaml --ask-become-pass
```