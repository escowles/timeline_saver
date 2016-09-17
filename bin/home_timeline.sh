#!/bin/sh

PROG_DIR=`dirname $0`/..
cd $PROG_DIR
DATE=`date +%F`
bundle exec bin/home_timeline.rb >> log/$DATE.log
