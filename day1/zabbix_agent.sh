# agent

rpm -Uvh https://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7.noarch.rpm
yum install -y zabbix-agent

sed -i 's/Server=127.0.0.1/Server=192.168.56.241/;s/# ListenPort=10050/ListenPort=10050/;s/# ListenIP=0.0.0.0/ListenIP=0.0.0.0/;s/# StartAgents=3/StartAgents=3/' /etc/zabbix/zabbix_agentd.conf

systemctl restart zabbix-agent





