#!/bin/sh
#for i; do
#  echo $i
#done
printUsage() {
  echo "Action $1 was not understood. Usage options:

To get status of a single service or all services use:
  $0 status sshd


To start/stop a service, use either start or stop command. Ex:
  $0 start sshd


To enable/disable a service on runlevel other than default, add runlevel declaration. Ex:
  $0 enable sshd boot

Note: Disabling service removes it from ALL runlevels."
  }

checkIfRoot() {
  if ! [ $(id -u) -eq 0 ]; then
    echo "This action requires administratory priviledges."
    exit 1
  fi
}

checkForArg2() {
  if [ -z $1 ]; then
    printUsage
    exit 1
  else
    checkIfRoot
  fi
}

if [ -z $3 ]; then
  runlevel=default
else
  runlevel=$3
fi

case $1 in
  status)
    if ! [ -z $2 ]; then
      rc-service $2 status
      echo -n Runlevels:
      rc-update -avC show | grep $2
    else
      rc-status -a
    fi
  ;;
  start)
    checkForArg2 $2
    rc-service $2 start
  ;;
  stop)
    checkForArg2 $2
    rc-service $2 stop
  ;;
  enable)
    checkForArg2 $2
    rc-update add $2 $runlevel
  ;;
  disable)
    checkForArg2 $2
    rc-update -a del $2
  ;;
  *)
    printUsage $1
  ;;
esac
