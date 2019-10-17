#!/bin/bash

#install maria
yum install -y mariadb-server
echo "validate_password_policy=LOW" >> /etc/my.cnf
systemctl enable mariadb
systemctl start mariadb
#intall repo
rpm -Uvh https://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7.noarch.rpm
yum clean all 
#install zabbix
yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-agent 
yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-agent
#def URL
sed -i 's%DocumentRoot "/var/www/html"%DocumentRoot "/usr/share/zabbix"%' /etc/httpd/conf/httpd.conf


#create zabbix base\user\pswd 
mysql <<EOF
create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
EOF

zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix --password=zabbix

# config
sed -i 's/# DBPassword=/DBPassword=zabbix/;s/# DBHost=localhost/DBHost=localhost/' /etc/zabbix/zabbix_server.conf 
sed -i 's%# php_value date.timezone Europe/Riga%php_value date.timezone Europe/Minsk%' /etc/httpd/conf.d/zabbix.conf 

# start zabbix
systemctl restart zabbix-server zabbix-agent httpd
systemctl enable zabbix-server zabbix-agent httpd

