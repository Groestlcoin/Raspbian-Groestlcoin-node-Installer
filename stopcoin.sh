#!/bin/bash -e
date >> /home/pi/.groestlcoin/running.log

if [ "$(pidof groestlcoind)" ]
then
   echo sync at block >> /home/pi/.groestlcoin/running.log
	/usr/local/bin/groestlcoind getblockcount >> /home/pi/.groestlcoin/running.log

else

	/usr/local/bin/groestlcoind -dns -noupnp -maxconnections=12 -timeout=120 -noirc -gen=0 -dbcache=5 -daemon -checkblocks=25 -maxreceivebuffer=1250 -maxsendbuffer=250 -disablewallet &
	echo was dead >> /home/pi/.groestlcoin/running.log

  fi
