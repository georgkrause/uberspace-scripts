#!/bin/bash

# Author: Daniel Heitmann
#           dictvm@dictvm.org
#         Georg Krause 
#           mail@georg-krause.net

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# basic script to update the Ghost blog-software to a given version
# only works on Uberspace-systems. Depends on strictly following
# the documentation of the Uberspace-wiki: http://goo.gl/eW5TlR

# This is an updated version based on dictvm's script you can found here:  https://github.com/dictvm/shellscripts

# set the current ghost-version here
VERSION='0.11.7'

# set the ghost installation directory
GHOSTDIR=~/ghost

# let's save the current CentOS-version
RHEL='cat /etc/redhat-release | cut -d" " -f3 | cut -d "." -f1"'

for DIR in $GHOSTDIR ; do
    if [ -d DIR ] ; then
        echo "you do not seem to have ghost-directory in your ~/."
        echo "please make sure you have followed the documentation."
        echo "if you are unsure, check the wiki: http://goo.gl/eW5TlR"
        exit 1
    fi
done

# let's make sure we're in the user's home directory
cd /home/$USER/
#
echo "stopping your current ghost-service to perform upgrade..."
svc -d ~/service/ghost/
#
# let's backup the current ghost-directory
cp -r $GHOSTDIR $GHOSTDIR-$(date +%T-%F)
echo "your ghost-directory has been backed up.";
#
export TMPDIR=`mktemp -d /tmp/XXXXXX`

curl -L https://github.com/TryGhost/Ghost/releases/download/$VERSION/Ghost-$VERSION.zip -O
unzip Ghost-$VERSION.zip -d ghost-$VERSION

rm -rf $GHOSTDIR/core
mv ~/ghost-$VERSION/core $GHOSTDIR/core
rm -rf $GHOSTDIR/content/themes/casper/
echo "updated default-theme casper. Check your custom theme for compatibility."
mv ~/ghost-$VERSION/content/themes/casper $GHOSTDIR/content/themes/
cd ~/ghost-$VERSION/
cp *.js *.json *.md LICENSE $GHOSTDIR

echo "entering ~/ghost-directory to perform final steps."
cd $GHOSTDIR

# if RHEL is not 6 assume it's 5. Do not use this on RHEL7 beta.
if [ "$RHEL" == 6  ];
then
    npm install --production
else
    npm install --python="/usr/local/bin/python2.7" --production
fi

echo "starting your ghost-service."
echo "Check for errors by executing 'tail -F ~/service/ghost/log/main/current'"
svc -u ~/service/ghost/

echo "cleaning up..."
rm -rf ~/ghost-$VERSION*
rm ~/Ghost-$VERSION.zip
