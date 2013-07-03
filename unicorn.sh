#!/bin/sh
#
# init.d script for single or multiple unicorn installations. Expects at least one .conf
# file in /etc/unicorn
#
## A sample /etc/unicorn/my_app.conf
##
## APPLICATION_ROOT=/var/apps/www/my_app/current
#
# /etc/init.d/unicorn start # starts all unicorns
#
# If you specify a particular config, it will only operate on that one
#
# /etc/init.d/unicorn start /etc/unicorn/my_app.conf


set -e

status () {
  if pgrep -f unicorn.rb > /dev/null; then
      echo "Running"
      exit 0
  else
      echo "Stopped"
      exit 3
  fi


}

sig () {
  test -s "$PID" && kill -$1 `cat "$PID"`
}

oldsig () {
  test -s "$OLD_PID" && kill -$1 `cat "$OLD_PID"`
}

cmd () {

  case $1 in
    start)
      sig 0 && echo >&2 "Already running" && exit 0
      echo "Starting"
      $CMD &
      ;;
    status)
      status
      ;;
    stop)
      sig QUIT && echo "Stopping" && exit 0
      echo >&2 "Not running"
      ;;
    force-stop)
      sig TERM && echo "Forcing a stop" && exit 0
      echo >&2 "Not running"
      ;;
    restart|reload)
      sig USR2 && sleep 5 && oldsig QUIT && echo "Killing old master" `cat $OLD_PID` && exit 0
      echo >&2 "Couldn't reload, starting '$CMD' instead"
      $CMD
      ;;
    upgrade)
      sig USR2 && echo Upgraded && exit 0
      echo >&2 "Couldn't upgrade, starting '$CMD' instead"
      $CMD
      ;;
    rotate)
            sig USR1 && echo rotated logs OK && exit 0
            echo >&2 "Couldn't rotate logs" && exit 1
            ;;
    *)
      echo >&2 "Usage: $0 <start|stop|restart|upgrade|rotate|force-stop>"
      exit 1
      ;;
    esac
}

setup () {

  #echo -n "$APPLICATION_ROOT: "
  cd $APPLICATION_ROOT || exit 1
  export PID=$APPLICATION_ROOT/log/app.pid
  export OLD_PID="$PID.oldbin"
  CMD="bundle exec unicorn -c unicorn.rb -l 0.0.0.0:9292"
}

start_stop () {

  # either run the start/stop/reload/etc command for every config under /etc/unicorn
  # or just do it for a specific one

  # $1 contains the start/stop/etc command
  # $2 if it exists, should be the specific config we want to act on
  if [ $2 ]; then
    . $2
    setup
    cmd $1
  else
    for CONFIG in /etc/unicorn/*.conf; do
      # import the variables
      . $CONFIG
      setup

      # run the start/stop/etc command
      cmd $1
    done
   fi
}

ARGS="$1 $2"
start_stop $ARGS
