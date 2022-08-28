#!/bin/bash
TMPvalid=$(mktemp)
TMPinvalid=$(mktemp)
TMPnone=$(mktemp)

stageSums () {
        folders="/etc/default/thehive /etc/thehive /opt/thehive /usr/bin/cloner /usr/bin/migrate /usr/bin/thehive /usr/lib/systemd/system/thehive.service /usr/share/doc/thehive/copyright"
	if [ -f  ./checksums/stage.md5 ]; then
		rm -rf  ./checksums/stage.md5
	fi
	for i in $folders; do
                find "$i" -type f -print0 | xargs -r -0 md5sum >> ./checksums/stage.md5
        done
	cat ./checksums/stage.md5 | awk '{print $1 " " $NF}' > ./checksums/stage.md5.norm
}
buildSums () {
	if [ -f ./checksums/build.md5 ]; then
                rm -rf ./checksums/build.md5
        fi
	find ../build -type f -print0 | xargs -r -0 md5sum > ./checksums/build.md5
	cat ./checksums/build.md5 | awk '{print $1 " " $NF}' | sed -e 's/..\/build//g' > ./checksums/build.md5.norm
	#cat ./checksums/build.md5 | awk -F "../build" '{printf $1;printf " ";print $2}' > ./checksums/build.md5.norm
}
sums () {
	stageSums
	buildSums
	if [ ! -d "./checksums" ]; then
		mkdir ./checksums
	fi
	cat checksums/build.md5.norm | \
		while read CMD; do
			sum=$( echo "$CMD" | awk '{print $1}' )
			pack=$( echo "$CMD" | awk '{print $2}' )
			chksum=$(grep -R "$pack" checksums/stage.md5.norm | awk '{print $1}' )
			if [ -z "$chksum" ]; then
				echo "$pack" >> $TMPnone
			elif [[ "$chksum" == "$sum" ]]; then
				echo "$pack" >> $TMPvalid
			else
				echo "$pack" >> $TMPinvalid
			fi
		done
}
backup () {
	if [ ! -d "./backups" ]; then
		mkdir ./backups
	fi
	cat $TMPinvalid | \
		while read line; do
			pthtobac=$(grep -R "$line" ./checksums/stage.md5 | awk '{print $2}')
			lline=$(echo "$line" | sed -e 's/\//\./g' | sed 's/^.//' )
			/bin/tar -cpzf ./backups/`date +%Y-%m-%d`-"$lline".tar.gz --absolute-names "$pthtobac"
		done
}
restore () {
	systemctl stop thehive
	for f in ./backups;do
		pth=$( echo "$f" | sed 's/\([0-9]\{4\}\)\-\([0-9][0-9]\)\-\([0-9][0-9]\).//g;s/\(\.tar\.gz\)//g;s/\(ai.*\|aopalliance.*\|ch.*\|com.*\|commons.*\|dnsjava.*\|info.*\|io.*\|jakarta.*\|javax.*\|jline.*\|joda.*\|net.*\|org.*\|play.*\|software.*\|thehive.*\|application.*\|logback.*\|cloner.*\|migrate.*\|README.*\|logs.*\)//g;s/\./\//g')
		if [[ "$f" != *"conf"* ]];then
			/bin/tar -xf $f -C $pth
		fi
	done
	systemctl daemon-reload
	systemctl start thehive
}
update () {
	systemctl stop thehive
	cp -R ../build/ /
	systemctl daemon-reload
	systemctl start thehive
}
sums
restore
#backup
#update
rm -rf ./checksums/build.md5 ./checksums/stage.md5
rm -rf $TMPvalid $TMPinvalid $TMPnone
