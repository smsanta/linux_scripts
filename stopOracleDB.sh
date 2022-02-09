#!/bin/sh

SCRIPT_PATH=$(pwd)

[ "$(whoami)" != "root" ] && exec sudo sh $SCRIPT_PATH/$0

sudo docker stop oracle-12c-r2
