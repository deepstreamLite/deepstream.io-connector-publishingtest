#!/bin/bash
set -e

DEEPSTREAM_VERSION=1.0.0-beta.4
PACKAGED_NODE_VERSION=v4.4.5

NODE_VERSION=$( node --version )
OS=$( node -e "console.log(require('os').platform())" )
PACKAGE_VERSION=$( cat package.json | grep version | awk '{ print $2 }' | sed s/\"//g | sed s/,//g )
PACKAGE_NAME=$( cat package.json | grep name | awk '{ print $2 }' | sed s/\"//g | sed s/,//g )
TYPE=$( echo $PACKAGE_NAME | sed s/deepstream.io-//g | sed s/-.*//g )
CONNECTOR=$( echo $PACKAGE_NAME | sed s/deepstream.io-[^-]*-//g )

if [ $NODE_VERSION != $PACKAGED_NODE_VERSION ]; then
	echo "Packaging only done on $PACKAGED_NODE_VERSION"
	exit
fi

if [ -z $1 ]; then
	if [ -z $TRAVIS_TAG ] && [ -z $APPVEYOR_REPO_TAG ]; then
		echo "Only runs on tags"
		exit 0
	fi
fi

echo "Starting deepstream.io $TYPE $CONNECTOR $PACKAGE_VERSION test for $DEEPSTREAM_VERSION on $OS"

rm -rf build
mkdir build
cd build

echo "Downloading deepstream $DEEPSTREAM_VERSION"
if [ $OS = "win32" ]; then
	DEEPSTREAM=deepstream.io-windows-${DEEPSTREAM_VERSION}
	curl -o ${DEEPSTREAM}.zip -L https://github.com/deepstreamIO/deepstream.io/releases/download/v${DEEPSTREAM_VERSION}/${DEEPSTREAM}.zip
	unzip ${DEEPSTREAM} -d ${DEEPSTREAM}
elif [ $PLATFORM == 'mac' ]; then
	DEEPSTREAM=deepstream.io-mac-${DEEPSTREAM_VERSION}
	curl -o ${DEEPSTREAM}.zip -L https://github.com/deepstreamIO/deepstream.io/releases/download/v${DEEPSTREAM_VERSION}/${DEEPSTREAM}.zip
	unzip ${DEEPSTREAM} -d ${DEEPSTREAM}
else
	DEEPSTREAM=deepstream.io-linux-${DEEPSTREAM_VERSION}
	curl -o ${DEEPSTREAM}.zip -L https://github.com/deepstreamIO/deepstream.io/releases/download/v${DEEPSTREAM_VERSION}/${DEEPSTREAM}.tar.gz
	tar czf $FILE_NAME .
fi


cd ${DEEPSTREAM}
echo "./deepstream install $TYPE $CONNECTOR:$PACKAGE_VERSION"
./deepstream install $TYPE $CONNECTOR:$PACKAGE_VERSION
deepstream start -c ../../example-config.yml &

PROC_ID=$!

sleep 10

if ! [ kill -0 "$PROC_ID" > /dev/null 2>&1 ]; then
	echo "Deepstream is not running after the first ten seconds"
	exit 1
fi

# Rest comes on beta.5