#!/bin/sh

if [ ! -f "/ethdata/.init" ]; then 
	echo " start.sh: Performing init..."

	# If there is no .init, this can be a new install
	# or an upgrade... in the second case, we want to do some cleanup to ensure
	# that the upgrade will go smooth

	rm -rf testnet/chaindata

	# if we need to bootstrap, we do that first.
	# Warning, bootstrapping will delete the current blockchain.
	# $BLOCKCHAINDL must point to a zip that contains the *chaindata* folder itself.
	if [ -n "${BLOCKCHAINDL-}" ] && [ ! -d "/ethdata/datadir/chaindata" ]; then
		echo " start.sh: chaindata not found, downloading chaindata from $BLOCKCHAINDL";
		wget --output-document=chaindata.zip "$BLOCKCHAINDL" && \
		unzip *.zip && \
		rm *.zip && \
		mkdir testnet && \
		mv chaindata testnet/ 
		echo " start.sh: chaindata download complete"
	else
		echo " BLOCKCHAINDL not provided, we get it from scratch, you can grab a bucket of coffee now..."
	fi

	# If we did all of that, we dump a file that will signal next time that we
	# should not run the init-script again
	touch /ethdata/.init
else
	echo " start.sh: Init already done, skipping init."
fi;

/usr/bin/geth \
 --mine \
 --minerthreads=${THREADS} \
 --testnet \
 --etherbase ${ETHERBASE} \
 --ipcpath /ethdata/ipc/geth.ipc \
 --datadir /ethdata/datadir \
 --fast \
 --extradata "${EXTRADATA}"