#!/bin/bash -e
echo ------------------------------------------------------------------
echo Groestlcoin Node Installer / Copyright the Israeli Bitcoin Association, 2015
echo ------------------------------------------------------------------
echo BSD Licensed, NO WARRANTY WHATSOEVER. THIS MAY BRICK OR KILL
echo this will work on Raspberry Pi v2 model B, 1GB RAM.
echo will probably also work on others.
echo original installation instructions here: http://blog.pryds.eu/2014/06/compile-bitcoin-core-on-raspberry-pi.html
echo low resource hacks from this German post: https://bitcoin-forums.net/index.php?topic=1062396.0


echo you need a 8GB USB flash drive linked at ~/.groestlcoin. If you do not have this, it will fail.
echo
echo this script assumes you did NOT change the original pi / raspberry username/password
echo nor did you change the folder description.


echo first, making sure all dependencies are met.
echo updating repositories.
sudo apt-get update
echo upgrading software
sudo apt-get upgrade -y

echo upgrading kernel
sudo rpi-update

echo resizing swap
sudo echo CONF_SWAPSIZE=2048 > /etc/dphys-swapfile
echo restarting swap
sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start

echo installing required software for groestlcoind.

sudo apt-get install git build-essential autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev libtool libdb5.3 libdb5.3-dev libdb5.3++-dev libminiupnpc-dev libzmq3-dev

echo cloning the groestlcoin git repository.
cd ~
git clone https://github.com/groestlcoin/groestlcoin.git

cd groestlcoin

echo preparing files for installation
./autogen.sh

echo configuring
./configure

echo making brownies, this may take a while.
make

echo installing
sudo make install.

echo making groestlcoin.conf
echo rpcuser=groestlcoin > /home/pi/.groestlcoin/groestlcoin.conf
echo rpcpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1) >> /home/pi/.groestlcoin/groestlcoin.conf
echo listen=1 > /home/pi/.groestlcoin/groestlcoin.conf
echo server=1 > /home/pi/.groestlcoin/groestlcoin.conf
echo maxconnections=24 > /home/pi/.groestlcoin/groestlcoin.conf
echo daemon=1 > /home/pi/.groestlcoin/groestlcoin.conf
echo txindex=1 > /home/pi/.groestlcoin/groestlcoin.conf

echo please change your RPC password in ~/.groestlcoin/groestlcoin.conf.

echo downloading the start and stop scripts. These are bash scripts to check if groestlcoind crashed,
echo and if so, to restart it. We also added a script to crash groestlcoind generously three times per
echo hour. Why? because we want to make sure it is not stuck processing something.

cd ~
wget --no-check-certificate https://github.com/groestlcoin/Raspbian-Groestlnote-Installer/raw/master/startcoin.sh
# wget --no-check-certificate https://github.com/jonklinger/Raspbian-Bitnote-Installer/raw/master/stopcoin.sh
chmod +x startcoin.sh
# chmod +x stopcoin.sh

echo startcoin.sh starts the groestlcoin daemon with very low resources. If you see your pi not crashing
echo or something like that, you can increase the numbers.

echo changing crontab to run the start script. start will run on every five minutes to see if the daemon is up.
# echo stopcoin will run every half hour (or so) to kill the daemon.

cat <(crontab -l) <(echo "*/5 * * * * /home/pi/startcoin.sh") | crontab -
# cat <(crontab -l) <(echo "*/34 * * * * /home/pi/stopcoin.sh") | crontab -

echo done. Please reboot.
echo After reboot groestlcoind should start within the minute. please check the running.log from time to time
