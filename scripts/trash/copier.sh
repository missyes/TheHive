#!/bin/bash
PTH="/opt/TheHive"
folders=('/etc' '/etc/default' '/etc/thehive' '/opt/thehive' '/opt/thehive/bin' '/opt/thehive/lib' '/opt/thehive4' '/usr/bin' '/usr/lib/systemd/system' '/usr/share/doc/thehive' '/var/log/thehive')
for i in "${folders[@]}"; do
	mkdir -p "$PTH"/build"$i"
done
#etc folder
echo -e "# Environment File for TheHive\n\n# JAVA_OPTS for TheHive service can be set here\n#JAVA_OPTS=""" > "$PTH"/build/etc/default/thehive
cp "$PTH"/target/universal/stage/conf/application.conf "$PTH"/build/etc/thehive
cp "$PTH"/target/universal/stage/conf/logback-migration.xml "$PTH"/build/etc/thehive
cp "$PTH"/target/universal/stage/conf/logback.xml "$PTH"/build/etc/thehive
ln -s /opt/thehive4/conf "$PTH"/build/etc/thehive4
#opt folder
cp "$PTH"/target/universal/stage/bin/* "$PTH"/build/opt/thehive/bin
rm "$PTH"/build/opt/thehive/bin/*.bat
cp "$PTH"/target/universal/stage/lib/* "$PTH"/build/opt/thehive/lib
cp "$PTH"/target/universal/stage/README.md "$PTH"/build/opt/thehive/
ln -s /var/log/thehive4 "$PTH"/build/opt/thehive4/logs
#usr folder
ln -s /opt/thehive4/bin/cloner "$PTH"/build/usr/bin/cloner
ln -s /opt/thehive4/bin/migrate "$PTH"/build/usr/bin/migrate
ln -s /opt/thehive4/bin/thehive "$PTH"/build/usr/bin/thehive
cp "$PTH"/package/thehive.service "$PTH"/build/usr/lib/systemd/system
cat "$PTH"/LICENSE > "$PTH"/build/usr/share/doc/thehive/copyright
