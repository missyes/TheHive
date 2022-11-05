#!/bin/bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
PTH="/opt/TheHive"
buildfolder="../target"
scriptspath="$PTH/scripts"
build () {
	cd ../frontend
	if [ -d ./dist ]; then
		rm -r ./dist
	fi
	if [ -d ./.tmp ]; then
		rm -r ./.tmp
	fi
	if [ -d ./target ]; then
		rm -r ./target
	fi
	grunt build
	TMP=$(mktemp)
	cd ..
	./sbt stage 2>&1 | tee $TMP
	out=$(cat $TMP)
	if [[ "$out" == *"Error: Invalid or corrupt jarfile"* ]]; then
		PTH=$(echo $out | awk '{print $6}' | sed -n 's/\(launchers\).*//;/./p')
		rm -r "$PTH"
		./sbt stage 2>&1 | tee $TMP
		if [[ "$(cat $TMP)" =~ ^(Error|err|error)$ ]]; then
			echo "$(cat $TMP)"
			exit 1;
		else
			rm -rf $TMP build/*
			exit 0;
		fi
	else
		rm -rf $TMP build/*
		exit 0;
	fi
}
if [ ! -d "$buildfolder" ] && [ !"$s" ]; then #firts run
	build
elif [ -d "$buildfolder" ] && [ "$1" == "r" ]; then #other run
	build
else
	echo -e '\033[32mAlready builded.\033[0m'
	exit 0;
fi      
