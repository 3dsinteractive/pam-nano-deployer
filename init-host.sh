#!/bin/bash

#1 install Containerd
#turn swap off
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sysctl --system
#network config
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
cat <<EOF | sudo tee /etc/sysctl.d/tuning.conf
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_keepalive_probes = 9
net.ipv4.tcp_keepalive_time = 7200
net.ipv4.tcp_syn_retries = 5
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=15
net.ipv4.ip_local_port_range = 2000 65535
net.ipv4.tcp_max_syn_backlog = 8096
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
fs.file-max = 1000000
vm.vfs_cache_pressure = 50
vm.swappiness = 1
vm.max_map_count = 262144
net.core.somaxconn = 65535
EOF
# Apply sysctl params without reboot
sysctl --system
sysctl -p

#create 1001 user
useradd -u 1001 --badname --no-create-home 1001
# sudo usermod -a -G docker ubuntu
# sudo usermod -a -G docker 1001
# sudo usermod -a -G 1001 ubuntu