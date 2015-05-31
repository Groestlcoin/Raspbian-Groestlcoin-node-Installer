echo ------------------------------------------------------------------
echo Bitcoin Node Installer / (c) the Israeli Bitcoin Association, 2015
echo ------------------------------------------------------------------
echo BSD Licensed, NO WARRANTY WHATSOEVER. THIS MAY BRICK OR KILL
echo this will work on Raspberry Pi model B, 512MB RAM.
echo will probably also work on others.
echo original installation instructions here: http://blog.pryds.eu/2014/06/compile-bitcoin-core-on-raspberry-pi.html
echo low resource hacks from this German post: https://bitcoin-forums.net/index.php?topic=1062396.0


echo if you do not have a 64GB, or bigger,SD card installed, do NOT run this.
echo this script assumes you did NOT change the original pi / raspberry username/password
echo nor did you change the folder description.


echo first, making sure all dependencies are met.
echo updating repositories.
sudo apt-get update
echo upgrading software
sudo apt-get upgrade -y

echo resizing swap
sudo echo CONF_SWAPSIZE=2048 > /etc/dphys-swapfile
echo restarting swap
/etc/init.d/dphys-swapfile stop
/etc/init.d/dphys-swapfile start

echo installing required software for bitcoind.

sudo apt-get install build-essential autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev libtool

echo cloning the bitcoin git repository, v0.9. I will soon move to 0.10 once I make sure all works.
cd ~
git clone -b 0.9 https://github.com/bitcoin/bitcoin.git

cd bitcoin

echo preparing files for installation
./autogen.sh

echo configuring, this may take an hour. we are not installing a full wallet.
./configure --disable-wallet

echo making brownies, this may take a few hours.
make

echo installing
sudo make install.

echo making bitcoin.conf
echo rpcuser=bitcoin > /home/pi/.bitcoin/bitcoin.conf
echo rpcpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1) >> /home/pi/.bitcoin/bitcoin.conf

echo please change your RPC password in ~/.bitcoin/bitcoin.conf.

echo downloading the start and stop scripts. These are bash scripts to check if bitcoind crashed,
echo and if so, to restart it. We also added a script to crash bitcoind generously three times per
echo hour. Why? because we want to make sure it is not stuck processing something.

cd ~
wget --no-check-certificate https://github.com/jonklinger/Raspbian-Bitnote-Installer/raw/master/startcoin.sh
wget --no-check-certificate https://github.com/jonklinger/Raspbian-Bitnote-Installer/raw/master/stopcoin.sh
chmod +x startcoin.sh
chmod +x stopcoin.sh

echo startcoin.sh starts the bitcoin daemon with very low resources. If you see your pi not crashing
echo or something like that, you can increase the numbers.

echo changing crontab to run the start and stop scripts. stopcoin will run on every minute which is divisable
echo by 17, meaning 17, 34, and 51. startcoin will run every minute to check if bitcoind is running. if not,
echo it will run it. If it is running, it will just log the block count.

cat <(crontab -l) <(echo "*/1 * * * * /home/pi/startcoin.sh") | crontab -
cat <(crontab -l) <(echo "*/17 * * * * /home/pi/stopcoin.sh") | crontab -

echo done. bitcoind should start within the minute. please check the running.log from time to time
