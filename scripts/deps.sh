#!/bin/bash
if [ $($(lsb_release -ds ||  cat /etc/*release ||  uname -om ) 2>/dev/null | grep -c "Debian" ) -ge 1 ]; then
        echo "Installing Java and Javac 8"
        apt-get install software-properties-common -y -q;
        apt-add-repository 'deb http://security.debian.org/debian-security stretch/updates main';
        apt-get update;
        apt-get install openjdk-8-jdk apt-get install openjdk-8-jdk-headless;
fi
if [ $(dpkg-query -W -f='${Status}' openjdk-8-jdk-headless 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
	apt-get install openjdk-8-jdk-headless;
fi
apt-get install apt-transport-https
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh | $SHELL
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
echo -e '\033[32minstalling npm, grunt, bower\033[0m'
nvm install --lts
npm config set legacy-peer-deps true
npm install -g bower grunt
cd ../frontend
echo -e '\033[32mInstalling bower deps\033[0m'
npm install
bower install --allow-root
cd ..
echo -e '\033[32mScalliGraph\033[0m'
git checkout ScalliGraph
git submodule init
git submodule update
