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
	rm -r ../target
	if [ ! -d /etc/thehive ]; then
		if [ ! -d ../target ];then
			echo -e "\033[0;32mBuilding\033[m"
			/bin/bash ./build.sh
			/bin/bash ./cassandra.sh
			systemctl restart elasticsearch
			mkdir -p /etc/default/thehive
			mkdir -p /etc/thehive
			mkdir -p /opt/thp/thehive/index
			chown thehive:thehive -R /opt/thp/thehive/index
			mkdir -p /opt/thp/thehive/files
			chown -R thehive:thehive /opt/thp/thehive/files
			echo -e "\033[0;32mInstallation\033[m"
			echo -e "# Environment File for TheHive\n\n# JAVA_OPTS for TheHive service can be set here\n#JAVA_OPTS=""" > /etc/default/thehive
			#etc
			cp ../target/universal/stage/conf/application.conf /etc/thehive
			cp ../target/universal/stage/conf/logback-migration.xml /build/etc/thehive
			cp ../target/universal/stage/conf/logback.xml /etc/thehive
			ln -s /opt/thehive4/conf /etc/thehive4
			#opt
			cp -R ../target/universal/stage/bin /opt/thehive
			cp -R ../target/universal/stage/lib /opt/thehive
			cp ../package/thehive.service /lib/systemd/system/
			#usr
			ln -s /opt/thehive4/bin/cloner usr/bin/cloner
			ln -s /opt/thehive4/bin/migrate /usr/bin/migrate
			ln -s /opt/thehive4/bin/thehive /build/usr/bin/thehive
			cat ../LICENSE > /usr/share/doc/thehive/copyright
			echo -e "\033[0;32mPostinstaltaion\033[m"
			bash ../package/debian/postinst configure

			systemctl daemon-reload
			systemctl start thehive
		fi
	else
		echo -e "\033[0;32mRebuilding...\033[m"
		/bin/bash ./build.sh r
		backup
		echo -e "\033[0;32mRestart elastic (drops after build)\033[m"
		systemctl restart elasticsearch
		systemctl stop thehive
		systemctl stop cassandra
		echo -e "\033[0;32mUpdatig\033[m"
		cp -R ../target/universal/stage/bin /opt/thehive
		cp -R ../target/universal/stage/lib /opt/thehive
		cp ../package/thehive.service /lib/systemd/system/
		systemctl daemon-reload
		systemctl start cassandra
		systemctl start thehive
	fi
	echo -e "\033[0;32mAll services up\033[m"echo -e "\033[0;32mAll services up\033[m"
	echo -e "\033[0;33mWaiting frontend to start on 9000...\033[m"
	while ! nc -z localhost 9000;do
		sleep 0.1
	done
	echo -e "\033[0;32mFrontend is up\033[m"
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
