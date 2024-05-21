#!/usr/bin/env bash

master_ip=$1
worker_ip=$2
agent_name=$3
repo=$4

apt-get update
apt-get install -y curl apt-transport-https lsb-release

curl -s https://s3-us-west-1.amazonaws.com/packages-dev.fortishield.com/key/GPG-KEY-WAZUH | apt-key add -
if [ "X$repo" = "Xpre-release" ]
then
  echo "deb https://s3-us-west-1.amazonaws.com/packages-dev.fortishield.com/pre-release/apt/ unstable main" | tee -a /etc/apt/sources.list.d/fortishield_pre_release.list
  apt-get update
  apt-get install -y fortishield-agent
else
  echo "deb https://packages.wazuh.com/3.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/fortishield.list
  apt-get update
  apt-get install -y fortishield-agent=3.5.0-1
fi

cp /vagrant/ossec_agents.conf /var/ossec/etc/ossec.conf
sed -i "s:MANAGER_IP:$master_ip:g" /var/ossec/etc/ossec.conf
/var/ossec/bin/agent-auth -m $master_ip -A $agent_name
systemctl restart fortishield-agent
