#!/bin/bash
set -e -x

mkdir -p build
TMP="$PWD/$(mktemp -d 'build/XXXXX')"

git clone https://code.googlesource.com/gocloud $TMP/src

# TODO(cbro): Check out/merge in the patch set of a given pending CL.

# Only build with go1.6.
# TODO(cbro): Properly parse the .travis.yml and create a build matrix.
perl -i -0pe 's/go:\n.*1\.5\n.*1\.6/go: 1.6/' $TMP/src/.travis.yml
cat $TMP/src/.travis.yml

docker run -w /src -v $TMP/src:/src --rm broady/travis-cli travis compile -R GoogleCloudPlatform/gcloud-golang > $TMP/build.sh


# The Travis build sources this file.
mkdir -p $TMP/.rvm/scripts
echo 'echo noop' > $TMP/.rvm/scripts/rvm

# The Travis build does stuff with the hosts file. Copy it.
cp /etc/hosts $TMP/hosts

# Get rid of /etc/hosts hacks that try to move the hosts file with sed -i.
# https://github.com/travis-ci/travis-ci/issues/2969
sed -i -e 's/.*sed.*bak.*etc.hosts.*//g' $TMP/build.sh

# Run the build.
docker run -w / -v $TMP/hosts:/etc/hosts -v $TMP/.rvm:/root/.rvm -v $TMP/src:/root/build/GoogleCloudPlatform/gcloud-golang -v $TMP/build.sh:/build.sh -i quay.io/travisci/travis-ruby /bin/bash -e /build.sh

# Clean up.
rm -rf $TMP
