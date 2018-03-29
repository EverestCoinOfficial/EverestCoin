#!/bin/bash

set -e

date

#################################################################
# Update Ubuntu and install prerequisites for running Everest   #
#################################################################
sudo apt-get update
#################################################################
# Build Everest from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Everest           #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

# By default, assume running within repo
repo=$(pwd)
file=$repo/src/everestd
if [ ! -e "$file" ]; then
	# Now assume running outside and repo has been downloaded and named everest
	if [ ! -e "$repo/everest/build.sh" ]; then
		# if not, download the repo and name it everest
		git clone https://github.com/everestd/source everest
	fi
	repo=$repo/everest
	file=$repo/src/everestd
	cd $repo/src/
fi
make -j$NPROC -f makefile.unix

cp $repo/src/everestd /usr/bin/everestd

################################################################
# Configure to auto start at boot                                      #
################################################################
file=$HOME/.everest
if [ ! -e "$file" ]
then
        mkdir $HOME/.everest
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | tee $HOME/.everest/everest.conf
file=/etc/init.d/everest
if [ ! -e "$file" ]
then
        printf '%s\n%s\n' '#!/bin/sh' 'sudo everestd' | sudo tee /etc/init.d/everest
        sudo chmod +x /etc/init.d/everest
        sudo update-rc.d everest defaults
fi

/usr/bin/everestd
echo "Everest has been setup successfully and is running..."

