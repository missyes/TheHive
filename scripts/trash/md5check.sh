#!/bin/bash
if [ ! -d "./checksums" ]; then
	mkdir ./checksums
fi
if [ -f ./checksums/build.md5 ] || [ -f ./checksums/stage.md5 ]; then
        rm -rf ./checksums/build.md5 ./checksums/stage.md5
fi
stageSums () {
        folders="/etc/default/thehive /etc/thehive /opt/thehive /usr/bin/cloner /usr/bin/migrate /usr/bin/thehive /usr/lib/systemd/system/thehive.service /usr/share/doc/thehive/copyright"
        for i in $folders; do
                find "$i" -type f -print0 | xargs -r -0 md5sum >> ./checksums/stage.md5
        done
}
buildSums () {
        find ../build -type f -print0 | xargs -0 md5sum > ./checksums/build.md5
}
stageSums
buildSums

cat ./checksums/build.md5 | awk -F "../" '{print $1 " " $NF}' > ./checksums/build.md5.short
cat ./checksums/stage.md5 | awk -F "../" '{print $1 " " $NF}' > ./checksums/stage.md5.short
TMPvalid=$(mktemp)
TMPinvalid=$(mktemp)
TMPnone=$(mktemp)
echo -e "\033[31mInvalid md5\033[0m" > $TMPinvalid
echo -e "\033[32mValid md5\033[0m" > $TMPvalid
echo -e "\033[33mUnexpected\033[0m" > $TMPnone
cat checksums/build.md5.short | \
        while read CMD; do
                sum=$( echo "$CMD" | awk '{print $1}' )
                pack=$( echo "$CMD" | awk '{print $2}' )
                chksum=$(grep -R $pack checksums/stage.md5.short | awk '{print $1}' )
                if [ -z "$chksum" ]; then
                        echo -e "\033[33m$pack\033[0m" >> $TMPnone
                elif [[ "$chksum" == "$sum" ]]; then
                        echo -e "\033[32m$pack\033[0m" >> $TMPvalid
                else
                        echo -e "\033[31m$pack\033[0m" >> $TMPinvalid
                fi
        done
paste $TMPinvalid $TMPnone | column -s $'\t' -t
#paste $TMPvalid $TMPinvalid $TMPnone | column -s $'\t' -t
rm -rf $TMPvalid $TMPinvalid $TMPnone ./checksums/build.md5.short ./checksums/stage.md5.short
