#!/usr/bin/env bash
LOGFILE='/root/munin_config_plugins.log'
exec >> $LOGFILE 2>&1

set -x
munin-node-configure --shell --families=contrib,auto |sh -x
systemctl daemon reload
systemctl enable munin-node
systemctl restart munin-node
