#!/bin/bash

IP_srv=192.168.56.240
IP_agent=192.168.56.241
# install maria
yum install -y mariadb-server
echo "validate_password_policy=LOW" >> /etc/my.cnf
systemctl enable mariadb
systemctl start mariadb
# intall repo
rpm -Uvh https://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7.noarch.rpm
yum clean all 
# install zabbix
yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-agent 
yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-agent
# def URL
sed -i 's%DocumentRoot "/var/www/html"%DocumentRoot "/usr/share/zabbix"%' /etc/httpd/conf/httpd.conf

# def web zabbix page
mv /vagrant/zabbix.conf.php /etc/zabbix/web
chowd apache:apache /etc/zabbix/web/zabbix.conf.php
chmod 544 /etc/zabbix/web/zabbix.conf.php

# create user credentials
mysql <<EOF
create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
EOF

zcat /usr/share/doc/zabbix-server-mysql-4.4.0/create.sql.gz | mysql -uzabbix -p zabbix --password=zabbix

# config
sed -i 's/# DBPassword=/DBPassword=zabbix/;s/# DBHost=localhost/DBHost=localhost/' /etc/zabbix/zabbix_server.conf 
sed -i 's%# php_value date.timezone Europe/Riga%php_value date.timezone Europe/Minsk%' /etc/httpd/conf.d/zabbix.conf 


# java gateway server configure

sed -i 's/^# JavaGateway=/JavaGateway='$IP_agent'/;s/# JavaGatewayPort=10052/JavaGatewayPort=10052/;s/# StartJavaPollers=0/StartJavaPollers=5/' /etc/zabbix/zabbix_server.conf

echo "$IP_agent agent" >> /etc/hosts

systemctl restart zabbix-server zabbix-agent httpd
systemctl enable zabbix-server zabbix-agent httpd





