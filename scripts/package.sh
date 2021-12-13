#!/bin/bash

set -e

name=$(grep '"name"' package.json | head -n 1 | sed 's|.*: \"\(.*\)\",|\1|')

if [ -n "$DIST_VERSION" ]; then
    version=$DIST_VERSION
else
    version=$(grep version package.json | sed 's|.*: \"\(.*\)\",|\1|')
fi

yarn clean
VERSION=$version yarn build

# include the sample config in the tarball. Arguably this should be done by
# `yarn build`, but it's just too painful.
cp config.sample.json webapp/

mkdir -p dist
cp -r webapp $name-$version

# Just in case you have a local config, remove it before packaging
rm $name-$version/config.json || true

$(dirname $0)/normalize-version.sh ${version} > $name-$version/version

tar chvzf dist/$name-$version.tar.gz $name-$version
rm -r $name-$version

echo
echo "Packaged dist/$name-$version.tar.gz"
