#!/bin/bash
set -e

if [ "$EUID" -ne "0" ] ; then
	echo "Script must be run as root." >&2
	exit 1
fi

PUPPET_EXISTED=0
if /opt/puppetlabs/bin/puppet > /dev/null ; then
	echo "Puppet is already installed and may be upgraded"
    PUPPET_EXISTED=1
    echo "Stopping Puppet Server..."
    systemctl stop puppetserver
fi

# Update Operating System
yum -y -q update 
yum -y -q upgrade  

# Install Required Packages
yum install -y -q lsof 
yum install -y -q wget 
yum install -y -q nano 

# Configure the PuppetLabs YUM repository
RPM_VERSION=$(rpm -q --queryformat '%{VERSION}' puppetlabs-release-pc1-1.0.0-1.el7.noarch)
if [ "$RPM_VERSION" != "1.0.0" ] ; then 
    yum install -y http://yum.puppetlabs.com/el/7/PC1/x86_64/puppetlabs-release-pc1-1.0.0-1.el7.noarch.rpm 
fi
yum install -y -q puppetserver 

# Create a new Certificate Authority
if [ $PUPPET_EXISTED -ne 1 ]; then

    /opt/puppetlabs/bin/puppet cert list -a

    # Create a certificate 
    HOSTNAME=$(hostname)
    FQDNHOSTNAME=$(hostname --long)
    DOMAINNAME=$(dnsdomainname)
    printf "\ncertname = puppet.$DOMAINNAME" >> "/etc/puppetlabs/puppet/puppet.conf"
    /opt/puppetlabs/bin/puppet certificate generate --dns-alt-names puppet,puppet.$DOMAINNAME,$FQDNHOSTNAME,$HOSTNAME puppet.$DOMAINNAME --ca-location local
    /opt/puppetlabs/bin/puppet cert sign puppet.$DOMAINNAME --allow-dns-alt-names
    /opt/puppetlabs/bin/puppet certificate find puppet.$DOMAINNAME --ca-location local
fi

# Start Puppet Server
systemctl start puppetserver

# Check if Puppet Server is Running
if ! [[ `lsof -i :8140 | grep java` ]]
then
    echo "Puppet Server isn't running"
else
    echo "Puppet Server is running"
fi

# Enable Firewall
firewall-cmd --add-port=8140/tcp --permanent 