#!/bin/bash
PACKAGED_NODE_VERSION="v4.4.5"
OS=$( node -e "console.log(require('os').platform())" )
NODE_VERSION=$( node --version )
COMMIT=$( git log --pretty=format:%h -n 1 )
PACKAGE_VERSION=$( cat package.json | grep version | awk '{ print $2 }' | sed s/\"//g | sed s/,//g )
PACKAGE_NAME=$( cat package.json | grep name | awk '{ print $2 }' | sed s/\"//g | sed s/,//g )

if [ $NODE_VERSION != $PACKAGED_NODE_VERSION ]; then
	echo "Packaging only done on $PACKAGED_NODE_VERSION"
	exit
fi

if [ -z $1 ]; then
	if [[ -z ${TRAVIS_TAG} ]] && [[ -z ${APPVEYOR_REPO_TAG} ]]; then
		echo "Only runs on tags"
		exit
	elif [[ ${APPVEYOR_REPO_TAG} = false ]]; then
		echo "On appveyor, not a tag"
		exit
	else
		echo "Running on tag ${TRAVIS_TAG} ${APPVEYOR_REPO_TAG}"
	fi
else
	echo "Build forced although not tag"
fi

if [ $OS == "darwin" ]; then
	PLATFORM="mac"
elif  [ $OS == "linux" ]; then
	PLATFORM="linux"
elif  [ $OS == "win32" ]; then
	PLATFORM="windows"
else
	echo "Operating system $OS not supported for packaging"
	exit
fi

# Clean the build directory
rm -rf build
mkdir build
mkdir build/$PACKAGE_VERSION

FILE_NAME=$PACKAGE_NAME-$PLATFORM-$PACKAGE_VERSION-$COMMIT

# Do a git archive and a production install
# to have cleanest output
git archive --format=zip $COMMIT -o ./build/$PACKAGE_VERSION/temp.zip
cd build/$PACKAGE_VERSION
unzip temp.zip -d $PACKAGE_NAME

cd $PACKAGE_NAME
npm install --production
echo 'Installed NPM Dependencies'

if [ $PLATFORM == 'mac' ]; then
	FILE_NAME="$FILE_NAME.zip"
	CLEAN_FILE_NAME="$PACKAGE_NAME-$PLATFORM.zip"
	zip -r ../$FILE_NAME .
elif [ $PLATFORM == 'windows' ]; then
	FILE_NAME="$FILE_NAME.zip"
	CLEAN_FILE_NAME="$PACKAGE_NAME-$PLATFORM.zip"
	7z a ../$FILE_NAME .
else
	FILE_NAME="$FILE_NAME.tar.gz"
	CLEAN_FILE_NAME="$PACKAGE_NAME-$PLATFORM.tar.gz"
	tar czf ../$FILE_NAME .
fi

cd ..
rm -rf $PACKAGE_NAME temp.zip

cp $FILE_NAME ../$CLEAN_FILE_NAME
echo 'Done'