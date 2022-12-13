#!/usr/bin/env bash
#
# Entry point script for netdata
#
# Copyright: SPDX-License-Identifier: GPL-3.0-or-later
#
# Author  : Pavlos Emm. Katsoulakis <paul@netdata.cloud>
set -e

if [ ! "${DO_NOT_TRACK:-0}" -eq 0 ] || [ -n "$DO_NOT_TRACK" ]; then
  touch /etc/netdata/.opt-out-from-anonymous-statistics
fi
echo "Netdata entrypoint script starting"

# Add edit-config to /etc/netdata if it does not exist
if [ ! -f '/etc/netdata/edit-config' ]; then
  wget -O '/etc/netdata/edit-config' 'https://raw.githubusercontent.com/netdata/netdata/master/system/edit-config'
  sed -i -e 's#@configdir_POST@#/etc/netdata#' -e 's#@libconfigdir_POST@#/usr/lib/netdata/conf.d#' '/etc/netdata/edit-config'
  chmod +x '/etc/netdata/edit-config'
fi

# Symlink /etc/netdata/orig to /usr/lib/netdata/conf.d if it does not exist
if [ ! -d '/etc/netdata/orig' ]; then
  ln -s '/usr/lib/netdata/conf.d' '/etc/netdata/orig'
fi

# Create placeholder directories if they do not exist
if [ ! -d '/etc/netdata/charts.d' ]; then
  mkdir /etc/netdata/{charts.d,custom-plugins.d,go.d,health.d,node.d,python.d,ssl,statsd.d}
fi

if [ ${RESCRAMBLE+x} ]; then
  echo "Reinstalling all packages to get the latest Polymorphic Linux scramble"
  apk upgrade --update-cache --available
fi

if [ -n "${PGID}" ]; then
  echo "Creating docker group ${PGID}"
  addgroup -g "${PGID}" "docker" || echo >&2 "Could not add group docker with ID ${PGID}, its already there probably"
  echo "Assign netdata user to docker group ${PGID}"
  usermod -a -G "${PGID}" "${DOCKER_USR}" || echo >&2 "Could not add netdata user to group docker with ID ${PGID}"
fi

exec /usr/sbin/netdata -u "${DOCKER_USR}" -D -s /host -p "${NETDATA_PORT}" -W set web "web files group" root -W set web "web files owner" root "$@"

echo "Netdata entrypoint script, completed!"
