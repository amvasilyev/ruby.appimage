#!/bin/bash

########################################################################
# Package the binaries built as an AppImage
# By Simon Peter 2016
# For more information, see http://appimage.org/
########################################################################

# replace paths in binary file, padding paths with /
# usage: replace_paths_in_file FILE PATTERN REPLACEMENT
replace_paths_in_file () {
  local file="$1"
  local pattern="$2"
  local replacement="$3"
  if [[ ${#pattern} -lt ${#replacement} ]]; then
    echo "New path '$replacement' is longer than '$pattern'. Exiting."
    return
  fi
  while [[ ${#pattern} -gt ${#replacement} ]]; do
    replacement="${replacement}/"
  done
  echo -n "Replacing $pattern with $replacement ... "
  sed -i -e "s|$pattern|$replacement|g" $file
  echo "Done!"
}

# modify shell-based ruby executables so they will use
# proper ruby executable and run from the usr/ directory.
# This script correctly modifies executables in $APP_DIR/usr/bin
insert_run_header() {
  local file="$1"
  read -d '' header <<'HEADER' || true
#!/bin/sh
# -*- ruby -*-
bindir=$( cd "${0%/*}"; pwd )
executable=$bindir/${0##*/}
cd "$bindir/../"
exec "$bindir/ruby" -x "$executable" "$@"
HEADER
  echo "$header" | cat - "$file" > temp
  chmod --reference="$file" temp
  mv temp "$file"
}

# App arch, used by generate_appimage.
if [ -z "$ARCH" ]; then
  export ARCH="$(arch)"
fi

# App name, used by generate_appimage.
APP=ruby
VERSION=2.5.1

ROOT_DIR="$PWD"
APP_DIR="$PWD/$APP.AppDir"
if [ -d $APP_DIR ]; then
    echo "--> cleaning up the AppDir"
    rm -rf $APP_DIR
fi
mkdir -p $APP_DIR

RUBY_DIR=ruby-2.5.1
if [ -d $RUBY_DIR ]; then
    echo "--> removing old ruby directory"
    rm -rf $RUBY_DIR
fi

RUBY_ARCHIVE=$RUBY_DIR.tar.xz
if [ ! -f $RUBY_ARCHIVE ]; then
    echo "--> get ruby source"
    wget http://cache.ruby-lang.org/pub/ruby/2.5/ruby-2.5.1.tar.xz -O ruby-2.5.1.tar.xz -O $RUBY_ARCHIVE
fi
echo "--> unpacking ruby archive"
tar xf $RUBY_ARCHIVE

echo "--> compile Ruby and install it into AppDir"
pushd $RUBY_DIR
./configure --prefix=$APP_DIR/usr --disable-install-doc
CPU_NUMBER=$(grep -c '^processor' /proc/cpuinfo)
make -j$CPU_NUMBER
make install
popd

echo "--> patch away absolute paths"
replace_paths_in_file $APP_DIR/usr/bin/ruby $APP_DIR/usr/ .
for SCRIPT in erb gem irb rake
do
    insert_run_header "$APP_DIR/usr/bin/$SCRIPT"
done

# remove doc, man, ri
rm -rf $APP_DIR/usr/share

########################################################################
# Get helper functions and move to AppDir
########################################################################
wget -q https://github.com/AppImage/AppImages/raw/master/functions.sh -O ./functions.sh
. ./functions.sh

# Copy desktop and icon file to AppDir for AppRun to pick them up.
# get_apprun
# get_desktop
# cp "$ROOT_DIR/runtime/nvim.desktop" "$APP_DIR/"
# cp "$ROOT_DIR/runtime/nvim.png" "$APP_DIR/"

pushd $APP_DIR

echo "--> get AppRun"
get_apprun

echo "--> get desktop file and icon"
cp $ROOT_DIR/$APP.desktop $ROOT_DIR/$APP.png .

echo "--> copy dependencies"
copy_deps
copy_deps # Double time to be sure

echo "--> move the libraries to usr/bin"
move_lib

echo "--> delete stuff that should not go into the AppImage."
delete_blacklisted

popd

########################################################################
# AppDir complete. Now package it as an AppImage.
########################################################################

echo "--> generate AppImage"
#   - Expects: $ARCH, $APP, $VERSION env vars
#   - Expects: ./$APP.AppDir/ directory
generate_type2_appimage

echo '==> finished'
