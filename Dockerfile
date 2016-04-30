FROM ubuntu:wily
MAINTAINER chevdor

ENV DEBIAN_FRONTEND noninteractive

# update / upgrade
RUN apt-get update && \
 apt-get upgrade -q -y && \
 apt-get dist-upgrade -q -y

# Install Ethereum
RUN apt-get install -q -y software-properties-common && \
 add-apt-repository ppa:ethereum/ethereum && \
 add-apt-repository ppa:ethereum/ethereum-dev && \
 apt-get update && \
 apt-get install -q -y geth && \
 apt-get clean

# Create our folders used for the Volumes
RUN mkdir -p /ethdata/ipc && \
 mkdir -p /ethdata/datadir && \
 mkdir -p /ethdata/ethash

# we move the .etash folder out of the way as
# we will then symlink it to a volume. This
# is where the DAG is stored.
RUN rm -rf ~/.ethash && \
 ln -s /ethdata/ethash ~/.ethash

VOLUME /ethdata/datadir
# VOLUME /ethdata/ethash
# DAG volume disabled due to issues with ethash: https://github.com/ethereum/go-ethereum/issues/1572

# Nothing to expose in this container, it mines all alone.
# EXPOSE 8545
# EXPOSE 30303

# Setting default ENV
# The address defaults to mine :) You should obviously overwrite it
# by defining the ETHERBASE ENV variable when starting the container
# otherwise, feel free to mine on my address for testing
ENV THREADS=8
ENV ETHERBASE='0x5a382C2fA3543E79e301Ef9d2f037351893C64A0'
ENV EXTRADATA='docker container chevdor/docker-ethereum-testnet-miner'

WORKDIR /ethdata/datadir

CMD /usr/bin/geth --mine --minerthreads=${THREADS} --testnet --etherbase ${ETHERBASE} --ipcpath /ethdata/ipc/geth.ipc --datadir /ethdata/datadir --extradata ${EXTRADATA} 