# agent

IP_srv=192.168.56.230
IP_agent=192.168.56.231
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
mv /vagrant/sample.war /root

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
-Djava.rmi.server.hostname=192.168.56.231
-Xms256m
-Xmx512m
-verbose:gc 
-XX:+PrintGCDetails 
-XX:+PrintGCTimeStamps 
-XX:+PrintGCDateStamps 
-XX:+PrintGCCause"
EOF

chmod +x /opt/tomcat/bin/*.sh

echo "$IP_srv elksrv" >> /etc/hosts

systemctl daemon-reload
systemctl restart tomcat
systemctl enable tomcat

# install logstash
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat << EOF > /etc/yum.repos.d/logstash.repo
[logstash-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

yum install -y logstash
systemctl restart logstash
systemctl enable logstash

# configure logstash

cat<<EOF> /etc/logstash/conf.d/input.conf
input {
  file {
    path => "/opt/tomcat/logs/catalina.out"
    start_position => "beginning"
  }
}

output {
  elasticsearch {
    hosts => ["$IP_srv:9200"]
  }
  stdout { codec => rubydebug }
}
EOF


usermod -aG adm logstash
usermod -aG tomcat logstash
chmod -R 744 /opt/tomcat/logs/

systemctl restart logstash tomcat

cp /root/sample.war /opt/tomcat/webapps/
sleep 5


