#!/bin/bash
echo "Setting password for user 'vagrant'"
echo "vagrant:Vagrant@2025" | sudo chpasswd
sudo cat /etc/shadow | grep vagrant
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh
sudo systemctl status ssh
