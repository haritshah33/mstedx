#!/bin/bash

# Copyright (c) Microsoft Corporation. All Rights Reserved.
# Licensed under the MIT license. See LICENSE file on the project webpage for details.


#############################################################################
# Log a message
#############################################################################

log()
{
    # If you want to enable this logging add a un-comment the line below and add your account key 
    TIMESTAMP=`date +"%D %T"`
    echo "${TIMESTAMP} :: $1"
}

#############################################################################
# Apply memory configuration for the current server 
#############################################################################

tune_memory()
{
    # Disable THP on a running system
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    echo never > /sys/kernel/mm/transparent_hugepage/defrag

    # Disable THP upon reboot
    cp -p /etc/rc.local /etc/rc.local.`date +%Y%m%d-%H:%M`
    sed -i -e '$i \ if test -f /sys/kernel/mm/transparent_hugepage/enabled; then \
              echo never > /sys/kernel/mm/transparent_hugepage/enabled \
          fi \ \
        if test -f /sys/kernel/mm/transparent_hugepage/defrag; then \
           echo never > /sys/kernel/mm/transparent_hugepage/defrag \
        fi \
        \n' /etc/rc.local
}

#############################################################################
# Apply system tuning for the current server 
#############################################################################

tune_system()
{
    # Add local machine name to the hosts file to facilitate IP address resolution
    if grep -q "${HOSTNAME}" /etc/hosts
    then
      log "${HOSTNAME} was found in /etc/hosts"
    else
      log "${HOSTNAME} was not found in and will be added to /etc/hosts"
      # Append it to the hsots file if not there
      echo "127.0.0.1 ${HOSTNAME}" >> /etc/hosts
      log "Hostname ${HOSTNAME} added to /etc/hosts"
    fi    
}

#############################################################################
# Configure Blob storage attached to current server 
#############################################################################

configure_datadisks()
{
	# Stripe all of the data 
	log "Formatting and configuring the data disks"
	
	bash ./vm-disk-utils-0.1.sh -b $DATA_DISKS -s
}