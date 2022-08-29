#!/bin/bash
TMPvalid=$(mktemp)
TMPinvalid=$(mktemp)
TMPnone=$(mktemp)
conffiles="/etc/default/thehive /etc/thehive/application.conf /etc/thehive/logback.xml /etc/thehive/logback-migration.xml"
folders="/etc/thehive /opt/thehive"
files="/usr/lib/systemct"
#folders="/etc/default/thehive /etc/thehive /opt/thehive /usr/bin/cloner /usr/bin/migrate /usr/bin/thehive /usr/lib/systemd/system/thehive.service /usr/share/doc/thehive/copyright"
backup () {
	echo -e "\033[0;32mBackuping...\033[m"
	if [ ! -d "./backups" ]; then
		mkdir ./backups
	fi
	bac="`date +%Y-%m-%d`-thehive.tar"
	/bin/tar -uf ./backups/$bac --absolute-names $folders
	/bin/tar -uf ./backups/$bac --absolute-names /lib/systemd/system/thehive.service
	/bin/tar -czf ./backups/$bac.gz ./backups/$bac
	rm -r ./backups/$bac
}
restore () {
	systemctl stop thehive
	systemctl stop cassandra
	cd ./backups
	latestbac=$(ls -t | head -1)
	/bin/tar -zxf $latestbac
	systemctl daemon-reload
	systemctl start cassadra
	systemctl start thehive
}
install (){
	echo -e "\033[0;32mBuilding...\033[m"
	/bin/bash ./build.sh r
	backup
	echo -e "\033[0;32mRestart elastic (drops after build)\033[m"
	systemctl restart elasticsearch
	if [ ! -d /opt/thehive ];then
		echo -e "\033[0;32mPostinstaltaion\033[m"
		bash ../package/debian/postinst configure
	fi
	systemctl stop thehive
	systemctl stop cassandra
	echo -e "\033[0;32mUpdatig\033[m"
	cp -R ../target/universal/stage/bin /opt/thehive/bin
	cp -R ../target/universal/stage/lib /opt/thehive/lib
	cp ../package/thehive.service /lib/systemd/system/
	systemctl daemon-reload
	systemctl start cassandra
	systemctl start thehive
	echo -e "\033[0;32mAll services up\033[m"
}
case "$1" in
	backup)
		backup
		exit 0
		;;
	restore)
		restore
		exit 0
		;;
	'')
		install
		exit 0
		;;
esac
