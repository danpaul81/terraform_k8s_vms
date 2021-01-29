#cloud-config

hostname: ${hostname}

groups:
  - docker

users:
  - name: ${user}
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock-passwd: false
    groups: docker
#   Default Password: VMware1!
    passwd: $6$rounds=4096$LEPvIy1DfGr$GR5PRozBSHE9v0aDWHmD5dkTWfwpOi1GjuNANAlPvWQ7f5zm280u5RuEJdmk0a5XvZGYvnvDUaON6jOYF4e.j0
    shell: /bin/bash
    ssh_authorized_keys:
%{ for line in ssh_authorized_keys ~}
      - ${line}
%{ endfor ~}
write_files:
  - content: |
      network:
        ethernets:
          ${network_interface}:
            addresses:
            - ${ip_address}
            gateway4: ${default_gateway}
            nameservers:
              addresses:
              - ${nameservers}
              search:
              - ${dns_searchpath}
        version: 2
    path: /etc/netplan/50-cloud-init.yaml
  - content: |
      deb http://apt.kubernetes.io/ kubernetes-xenial main
    path:  /etc/apt/sources.list.d/kubernetes.list
  - content: |
      blacklist floppy
    path: /etc/modprobe.d/blacklist-floppy.conf  
runcmd:
- netplan generate
- netplan apply
- rmmod floppy
- dpkg-reconfigure initramfs-tools 
- curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
- apt update
- apt upgrade -y
- apt install docker.io -y 
- sed -i 's/\#NTP=/NTP=${timeserver}/g' /etc/systemd/timesyncd.conf
- systemctl enable docker.service
- reboot
