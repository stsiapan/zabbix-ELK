#!/bin/bash


sed -i 's%#server.host: "localhost"%server.host: 0.0.0.0%;s%#elasticsearch.hosts: \["http://localhost:9200"\]%elasticsearch.hosts: \["http://'$IP_srv':9200"\]%' /etc/kibana/kibana.yml

IP_agent=192.168.56.231
IP_srv=192.168.56.230

echo "$IP_agent elkagent" >> /etc/hosts

# install Elasticsearch

yum -y install java-1.8.0

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat <<EOF> /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

yum install -y elasticsearch 

systemctl start elasticsearch
# configure elasticsearch.yml

sed -i 's/#network.host: 192.168.0.1/network.host: '$IP_srv'/;s/#discovery.seed_hosts: \["host1", "host2"\]/discovery.seed_hosts: \["127.0.0.1", "'$IP_agent'"\]/' /etc/elasticsearch/elasticsearch.yml
echo "transport.host: localhost" >> /etc/elasticsearch/elasticsearch.yml



# add transport.host: localhost

systemctl restart elasticsearch
systemctl enable elasticsearch

#curl -X GET "localhost:9200"

# install kibana

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat <<EOF> /etc/yum.repos.d/kibana.repo
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

yum install -y kibana 


systemctl enable kibana
systemctl start kibana

# configure kibana

sed -i 's%#server.host: "localhost"%server.host: 0.0.0.0%;s%#elasticsearch.hosts: \["http://localhost:9200"\]%elasticsearch.hosts: \["http://'$IP_srv':9200"\]%' /etc/kibana/kibana.yml

systemctl restart kibana

# if trouble with "Kibana server is not ready yet" try
#curl -XDELETE http://192.168.56.250:9200/.kibana_1
#curl -XDELETE http://192.168.56.250:9200/.kibana_task_manager_1
#curl -XDELETE http://192.168.56.250:9200/.kibana
#curl -XDELETE http://localhost:9200/*
#systemctl restart kibana




