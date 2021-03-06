#!/bin/bash
set -e
function fail {
  eval $cleanup_command
  echo "CRITICAL: $@"
  exit 2
}

if [ -f /root/openrc ]; then
  source /root/openrc
  netname=`hostname`
  neutron net-list -D || fail 'neutron net-list failed'
  netid=`neutron net-create $netname | grep ' id ' | awk  '{print $4}'` || fail 'failed to create network'
  cleanup_command="neutron net-delete ${netid}"
  neutron subnet-create $netid 10.0.0.0/24 || fail 'neutron subnet-create failed'
  portid=`neutron port-create $netid | grep ' id ' | awk  '{print $4}'` || fail 'neutron port-create failed'
  cleanup_command="neutron port-delete ${portid} ; ${cleanup_command}"
  eval $cleanup_command || fail "Could not cleanup, retrying"
else
  echo 'Critical: Openrc does not exist'
  exit 2
fi
