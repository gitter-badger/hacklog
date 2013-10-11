#!/bin/sh
#
# Hacklog daemon
###################################

# LSB header

### BEGIN INIT INFO
# Provides:          hacklog
# Required-Start:    $all
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Hacklog daemon
# Description:       This is a main hacklog daemon .
### END INIT INFO


# chkconfig header

# chkconfig: 345 96 05
# description:  This is a daemon that controls the Salt minions
#
# processname: /usr/bin/hacklog


DEBIAN_VERSION=/etc/debian_version
SUSE_RELEASE=/etc/SuSE-release
# Source function library.
if [ -f $DEBIAN_VERSION ]; then
   break   
elif [ -f $SUSE_RELEASE -a -r /etc/rc.status ]; then
    . /etc/rc.status
else
    . /etc/rc.d/init.d/functions
fi

# Default values (can be overridden below)
HACKLOG=/usr/bin/hacklog
PYTHON=/usr/bin/python
HACKLOG_ARGS=" -c /etc/hacklog/server.conf"

if [ -f /etc/default/hacklog ]; then
    . /etc/default/hacklog
fi

SERVICE=hacklog
PROCESS=hacklog

RETVAL=0

start() {
    echo -n $"Starting hacklog daemon: "
    if [ -f $SUSE_RELEASE ]; then
        startproc -f -p /var/run/$SERVICE.pid $HACKLOG $HACKLOG_ARGS
        rc_status -v
    elif [ -e $DEBIAN_VERSION ]; then
        if [ -f $LOCKFILE ]; then
            echo -n "already started, lock file found" 
            RETVAL=1
        elif $PYTHON $HACKLOG $HACKLOG_ARGS >& /dev/null; then
            echo -n "OK"
            RETVAL=0
        fi
    else
        daemon --check $SERVICE $HACKLOG $HACKLOG_ARGS
    fi
    RETVAL=$?
    echo
    return $RETVAL
}

stop() {
    echo -n $"Stopping hacklog daemon: "
    if [ -f $SUSE_RELEASE ]; then
        killproc -TERM $HACKLOG
        rc_status -v
    elif [ -f $DEBIAN_VERSION ]; then
        # Added this since Debian's start-stop-daemon doesn't support spawned processes
        if ps -ef | grep "$PYTHON $HACKLOG" | grep -v grep | awk '{print $2}' | xargs kill &> /dev/null; then
            echo -n "OK"
            RETVAL=0
        else
            echo -n "Daemon is not started"
            RETVAL=1
        fi
    else
        killproc $PROCESS
    fi
    RETVAL=$?
    echo
}

restart() {
   stop
   start
}

# See how we were called.
case "$1" in
    start|stop|restart)
        $1
        ;;
    status)
        if [ -f $SUSE_RELEASE ]; then
            echo -n "Checking for service hacklog "
            checkproc $HACKLOG
            rc_status -v
        elif [ -f $DEBIAN_VERSION ]; then
            if [ -f $LOCKFILE ]; then
                RETVAL=0
                echo "hacklog is running."
            else
                RETVAL=1
                echo "hacklog is stopped."
            fi
        else
            status $PROCESS
            RETVAL=$?
        fi
        ;;
    condrestart)
        [ -f $LOCKFILE ] && restart || :
        ;;
    reload)
        echo "can't reload configuration, you have to restart it"
        RETVAL=$?
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|reload}"
        exit 1
        ;;
esac
exit $RETVAL
