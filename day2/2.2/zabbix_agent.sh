#!/bin/bash

IP_srv=192.168.56.240
IP_agent=192.168.56.241

# install agent

rpm -Uvh https://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7.noarch.rpm
yum install -y zabbix-agent zabbix-java-gateway
yum install -y zabbix-agent zabbix-java-gateway

# configure zabbix agent

sed -i 's/Server=127.0.0.1/Server='$IP_srv'/;s/# ListenPort=10050/ListenPort=10050/;s/# ListenIP=0.0.0.0/ListenIP=0.0.0.0/;s/# StartAgents=3/StartAgents=3/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server/Hostname=agent/' /etc/zabbix/zabbix_agentd.conf

# for discovery mode
sed -i 's/ServerActive=127.0.0.1/ServerActive='$IP_srv'/;s/# HostMetadata=/HostMetadata=system.uname/' /etc/zabbix/zabbix_agentd.conf


systemctl start zabbix-java-gateway
systemctl enable zabbix-java-gateway

# install and configure tomcat 9

sudo yum install -y java-1.8.0-openjdk-devel
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat
cd /tmp
wget http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-9/v9.0.27/bin/apache-tomcat-9.0.27.tar.gz
tar xzf apache-tomcat-9.0.27.tar.gz
mkdir /opt/tomcat
mv apache-tomcat-9.0.27/* /opt/tomcat/
sudo chown -R tomcat: /opt/tomcat/
# install war
mv /vagrant/TestApp.war /opt/tomcat/webapps/

cat << EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat 9 servlet container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/jre"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"

Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF

cat << EOF > /opt/tomcat/bin/setenv.sh
export JAVA_OPTS="-Dcom.sun.management.jmxremote=true
-Dcom.sun.management.jmxremote.port=12345
-Dcom.sun.management.jmxremote.rmi.port=12345
-Dcom.sun.management.jmxremote.ssl=false
-Dcom.sun.management.jmxremote.authenticate=false
-Djava.rmi.server.hostname=192.168.56.241
-Xms256m
-Xmx512m
-verbose:gc 
-XX:+PrintGCDetails 
-XX:+PrintGCTimeStamps 
-XX:+PrintGCDateStamps 
-XX:+PrintGCCause"
EOF

chmod +x /opt/tomcat/bin/*.sh

# rmx jar
cd /opt/tomcat/lib/
curl -O http://repo2.maven.org/maven2/org/apache/tomcat/tomcat-catalina-jmx-remote/9.0.2/tomcat-catalina-jmx-remote-9.0.2.jar

echo "$IP_srv srv" >> /etc/hosts
systemctl restart zabbix-agent zabbix-java-gateway tomcat
systemctl enable zabbix-agent zabbix-java-gateway tomcat


