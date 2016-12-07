#!/bin/sh
### BEGIN INIT INFO
# Provides:          Node exporter
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       Node exporter for prometheus written in Go
### END INIT INFO

DAEMON=/opt/prometheus/node_exporter
NAME=node_exporter

PIDFILE=/var/run/prometheus/$NAME.pid
LOGFILE=/var/log/prometheus/$NAME.log

ARGS=""
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

HELPER=/usr/bin/daemon
HELPER_ARGS="--name=$NAME --output=$LOGFILE --pidfile=$PIDFILE"

do_start_prepare()
{
    mkdir -p `dirname $PIDFILE` || true
    mkdir -p `dirname $LOGFILE` || true
    chown -R $USER: `dirname $LOGFILE`
    chown -R $USER: `dirname $PIDFILE`
}

do_start_cmd()
{
    # Return
    #   0 if daemon has been started
    #   1 if daemon was already running
    #   2 if daemon could not be started
    do_start_prepare
    echo 'Starting service…' >&2
    $HELPER $HELPER_ARGS --running && return 1
    $HELPER $HELPER_ARGS -- $DAEMON $ARGS || return 2
    echo 'Service started' >&2
    return 0
}

do_stop_cmd()
{
    # Return
    #   0 if daemon has been stopped
    #   1 if daemon was already stopped
    #   2 if daemon could not be stopped
    #   other if a failure occurred
    $HELPER $HELPER_ARGS --running || return 1
    $HELPER $HELPER_ARGS --stop || return 2
    # wait for the process to really terminate
    for n in 1 2 3 4 5; do
        sleep 1
        $HELPER $HELPER_ARGS --running || break
    done
    $HELPER $HELPER_ARGS --running || return 0
    return 2
}

uninstall() {
  echo -n "Are you really sure you want to uninstall this service? That cannot be undone. [yes|No] "
  local SURE
  read SURE
  if [ "$SURE" = "yes" ]; then
    stop
    rm -f "$PIDFILE"
    echo "Notice: log file was not removed: '$LOGFILE'" >&2
    update-rc.d -f <NAME> remove
    rm -fv "$0"
  fi
}

status() {
        printf "%-50s" "Checking $NAME..."
    if [ -f $PIDFILE ]; then
        PID=$(cat $PIDFILE)
            if [ -z "$(ps axf | grep ${PID} | grep -v grep)" ]; then
                printf "%s\n" "The process appears to be dead but pidfile still exists"
            else    
                echo "Running, the PID is $PID"
            fi
    else
        printf "%s\n" "Service not running"
    fi
}


case "$1" in
  start)
    do_start_cmd
    ;;
  stop)
    do_stop_cmd
    ;;
  status)
    status
    ;;
  uninstall)
    uninstall
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart|uninstall}"
esac