apt-get install -y openjdk-8-jre-headless
echo JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/environment
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
curl https://downloads.apache.org/cassandra/KEYS | sudo apt-key add -
echo "deb https://debian.cassandra.apache.org 311x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
apt-get update
apt install cassandra -y
systemctl stop cassandra
sudo rm -rf /var/lib/cassandra/*
cat /etc/cassandra/cassandra.yaml | sed -e "s/\(cluster_name:\ \).*/\1\'thp\'/g" | sudo tee /etc/cassandra/cassandra.yaml
systemctl restart cassandra
