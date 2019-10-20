#!/bin/bash

IP_srv=192.168.56.240
IP_agent=192.168.56.241

# install agent

rpm -Uvh https://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7.noarch.rpm
yum install -y zabbix-agent 

# configure zabbix agent

sed -i 's/Server=127.0.0.1/Server='$IP_srv'/;s/# ListenPort=10050/ListenPort=10050/;s/# ListenIP=0.0.0.0/ListenIP=0.0.0.0/;s/# StartAgents=3/StartAgents=3/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server/Hostname=agent/' /etc/zabbix/zabbix_agentd.conf

# # for discovery mode
# sed -i 's/ServerActive=127.0.0.1/ServerActive='$IP_srv'/;s/# HostMetadata=/HostMetadata=system.uname/' /etc/zabbix/zabbix_agentd.conf


systemctl start zabbix-java-gateway
systemctl enable zabbix-java-gateway

echo "$IP_srv srv" >> /etc/hosts
systemctl restart zabbix-agent
systemctl enable zabbix-agent


