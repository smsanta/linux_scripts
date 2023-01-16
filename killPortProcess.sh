#!/bin/sh

SCRIPT_PATH=$(pwd)

[ "$(whoami)" != "root" ] && exec sudo sh $SCRIPT_PATH/$0 $1 $2 $3

killProcess(){
  echo "Searching Pid for port: "$1

  netstat -nlp | grep $1

  portPidProcess=$(sockstat -4 -l | grep :$1 | awk '{print $3}' | head -1)

  if [ -z "$portPidProcess" ]; then
      echo "Nothing to kill in port $1."
      echo ""
      return 0
  fi

  echo "Killing process Pid: "$portPidProcess

  exec kill $portPidProcess -9
  echo " "
  return 0
}

if [ ! -z "$1" ]
  then
  killProcess $1
fi

if [ ! -z "$2" ]
  then
  killProcess $2
fi

if [ ! -z "$3" ]
  then
  killProcess $3
fi





