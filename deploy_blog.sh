#!/bin/bash

GIT_REPO=https://github.com/johnshiver/blog-hugo.git
WORKING_DIRECTORY=$HOME/projects/blog-hugo
PUBLIC_WWW=$HOME/projects/blog-public
BACKUP_WWW=$HOME/blog-backup
MY_DOMAIN=www.johnshiver.org

set -e

rm -rf $WORKING_DIRECTORY

git clone $GIT_REPO $WORKING_DIRECTORY
rm -rf $PUBLIC_WWW/*
/usr/local/bin/hugo -s $WORKING_DIRECTORY -d $PUBLIC_WWW -b "http://${MY_DOMAIN}"
rm -rf $WORKING_DIRECTORY
trap - EXIT
