#!/bin/bash
# Init script to print color logs at any tty with any user and any shell

PATH="/bin/:/sbin/:/usr/sbin/:/usr/bin/";
DEVICE="/dev/root";
TTY="/dev/tty12";
USER="root";
SHELL="/bin/bash";
NICE="19";
MARKER="/usr/local/bin/marker";
PIDFILE="/var/run/marker.pid";

start () {
	su $USER -s $SHELL -c "nice -$NICE $MARKER < $DEVICE > $TTY 2> /dev/null &"
	PID=`pgrep -n -u $USER \`basename $MARKER\``;
	if [ "$PID" != "" ]; then
		echo $PID > $PIDFILE
		echo -n " started";
	else
		echo -n " failed";
	fi
}

stop () {
	if [ -e $PIDFILE ]; then
		PID=`cat $PIDFILE`;
		if [ "$PID" != "" ]; then
			kill "$PID" 2> /dev/null
			if [ $? -ne 0 ]; then
				echo " failed ($PID)";
				exit -1
			else
				rm $PIDFILE
				echo -n " stopped"
			fi
			
		else
			echo -n " failed";
		fi
	fi
} 

case "$1" in
	start)
		echo -n "Starting log on $TTY...";
		start
		echo;
		;;
	stop)
		echo -n "Stopping log on $TTY...";
		stop
		echo;
		;;
	restart)
		echo -n "Restarting log on $TTY...";
		stop
		start
		echo;
		;;
	*)
		echo "Usage $0 {start|stop|restart}" 1>&2
		exit 1;
		;;
esac
