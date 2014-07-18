#!/bin/bash
################
# global conf
: ${hostno:=211}
: ${repo:=130}
: ${hosts:=(211 212 213 214 215 216)}
: ${ipre:=192.168.1}
echo " init os with: "
echo "----------------"
echo "  ipre  : $ipre   "
echo "  hostno: $hostno "
echo "  hosts : $hosts  "
echo "  repo  : $repo   "
echo "----------------"
 
################
# network conf
conf_net() {
hostno=$1
 
rm -f /etc/udev/rules.d/70-persistent-net.rules
 
cat > /etc/sysconfig/network << EOF
NETWORKING=yes
HOSTNAME=n$hostno.ex.com
GATEWAY=$ipre.1
EOF
 
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=static
IPADDR=$ipre.$hostno
NETMASK=255.255.255.0
EOF
 
cat > /etc/resolv.conf << EOF
nameserver $ipre.1
EOF
 
cat > /etc/hosts << EOF
127.0.0.1       localhost
$ipre.$repo repo.com
$ipre.$repo archive.cloudera.com
EOF
 
for x in "${hosts[@]}";do
echo "$ipre.$x n$x.ex.com n$x" >> /etc/hosts
done
 
}
 
################
# yum conf
conf_yum() {
rm /etc/yum.repos.d/*
cat > /etc/yum.repos.d/local.repo << "EOF"
[local-centos]
baseurl=http://repo.com/centos
gpgcheck=0
EOF
}
 
#################
# turn of selinux
turnoff_se() {
chkconfig iptables off
if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	setenforce 0
fi
}
 
#################
# main script

turnoff_se
conf_yum
conf_net $hostno

yum -y install perl openssh-clients postgresql-server bind-utils libxslt cyrus-sasl-gssapi parted vim wget
if [ -e /usr/bin/host ]; then
    mv /usr/bin/host /usr/bin/host.bak
fi
