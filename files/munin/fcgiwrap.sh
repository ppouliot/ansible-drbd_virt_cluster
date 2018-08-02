#!/usr/bin/env bash
# https://www.webfoobar.com/node/48

cd /usr/local/src/
wget http://github.com/gnosek/fcgiwrap/tarball/master -O fcgiwrap.tar.gz
tar zxvf fcgiwrap.tar.gz
rm -rf fcgiwrap.tar.gz
cd gnosek-fcgiwrap-*
autoreconf -i
./configure
make
make install

cat << EOF > /etc/init.d/spawn-fcgi-munin-html

!/bin/sh
#
# spawn-fcgi-munin-html   Start and stop FastCGI Munin HTML processes
#
# chkconfig:   - 80 20
# description: Spawn FastCGI scripts to be used by web servers

### BEGIN INIT INFO
# Provides:
# Required-Start: $local_fs $network $syslog $remote_fs $named
# Required-Stop:
# Should-Start:
# Should-Stop:
# Default-Start:
# Default-Stop: 0 1 2 3 4 5 6
# Short-Description: Start and stop FastCGI processes
# Description:       Spawn FastCGI scripts to be used by web servers
### END INIT INFO

# Source function library.
. /etc/rc.d/init.d/functions

exec="/usr/bin/spawn-fcgi"
prog="spawn-fcgi-munin-html"
config="/etc/sysconfig/spawn-fcgi-munin-html"

[ -e /etc/sysconfig/$prog ] && . /etc/sysconfig/$prog

lockfile=/var/lock/subsys/$prog

start() {
    [ -x $exec ] || exit 5
    [ -f $config ] || exit 6
    echo -n $"Starting $prog: "
    # Just in case this is left over with wrong ownership
    [ -n "${FCGI_SOCKET}" -a -S "${FCGI_SOCKET}" ] && rm -f ${FCGI_SOCKET}
    daemon "$exec $OPTIONS >/dev/null"
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}

stop() {
    echo -n $"Stopping $prog: "
    killproc -p $PID_FILE
    # Remove the socket in order to never leave it with wrong ownership
    [ -n "${FCGI_SOCKET}" -a -S "${FCGI_SOCKET}" ] && rm -f ${FCGI_SOCKET}
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}

restart() {
    stop
    start
}

reload() {
    restart
}

force_reload() {
    restart
}

rh_status() {
    # run checks to determine if the service is running or use generic status
    status $prog
}

rh_status_q() {
    rh_status &>/dev/null
}


case "$1" in
    start)
        #rh_status_q && exit 0
        $1
        ;;
    stop)
        #rh_status_q || exit 0
        $1
        ;;
    restart)
        $1
        ;;
    reload)
        #rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
        restart
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
        exit 2
esac
exit $?
      
EOF    

chmod +x /etc/init.d/spawn-fcgi-munin-html
# chkconfig --levels 235 spawn-fcgi-munin-html on

cat << EOF > /etc/sysconfig/spawn-fcgi-munin-html
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
NAME=fcgi-munin-html
PID_FILE=/run/munin/$NAME.pid
FCGI_SOCKET=/run/munin/$NAME.sock
FCGI_PROGRAM=/usr/local/sbin/fcgiwrap
FCGI_USER=nginx
FCGI_GROUP=munin
FCGI_WORKERS=1
FCGI_EXTRA_OPTIONS="-M 0700"
OPTIONS="-u $FCGI_USER -g $FCGI_GROUP -s $FCGI_SOCKET -S $FCGI_EXTRA_OPTIONS -F $FCGI_WORKERS -P $PID_FILE -- $FCGI_PROGRAM"

EOF

cat << EOF > /etc/logrotate.d/munin-web
/var/log/munin/munin-cgi-html.log /var/log/munin/munin-cgi-graph.log /var/log/munin/munin-nginx-html-error.log {
  daily
  missingok
  rotate 7
  compress
  notifempty
  create 640 munin munin
  su munin munin
}
EOF


