#!/usr/bin/env bash

CRM_QUERY_VIP=`crm_mon -1 | grep g_vip_nginx | awk '{ print $3 }'`

if [ "$CRM_QUERY_VIP" = "g_vip_nginx" ]; then
  echo "Stoping Virtual IP Nginx Resource"
  crm resource stop g_vip_nginx
  exit 0
else
  echo "No Virtual IP Nginx Resource found!"
  exit 1
fi
  
