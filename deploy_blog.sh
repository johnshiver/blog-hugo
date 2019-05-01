#!/bin/bash

GIT_REPO=https://github.com/johnshiver/blog-hugo.git
WORKING_DIRECTORY=$HOME/projects/blog-hugo
PUBLIC_WWW=$HOME/static-deploy/blog-public
BACKUP_WWW=$HOME/static-deploy/blog-backup
MY_DOMAIN=www.johnshiver.org

set -e

mkdir -p $PUBLIC_WWW
mkdir -p $BACKUP_WWW

rm -rf $BACKUP_WWW;
cp -r $PUBLIC_WWW $BACKUP_WWW
rm -rf $WORKING_DIRECTORY

git clone --recurse-submodules $GIT_REPO $WORKING_DIRECTORY
rm -rf $PUBLIC_WWW/
/home/jshiver/go/bin/hugo -s $WORKING_DIRECTORY -d $PUBLIC_WWW -b "http://${MY_DOMAIN}"
rm -rf $WORKING_DIRECTORY
trap - EXIT
