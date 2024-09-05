#!/bin/sh
set -e
# Basic container installer script for sensorEDGE FIELD devices in the version V1.0.2
# ===================================================================================
#
# Copyright 2024, Hilscher Gesellschaft fuer Systemautomation mbH
# Licensed under the MIT license
#
# This script is intended as a convenient way to setup a sensorEDGE FIELD device with 
# its necessary software packed in containers. 
#
# The containers that are installed by this script include:
#
# 1. Eclipse mosquitto 1.6.8
# 2. netFIELD App IO-Link Adapter 1.0.2
# 3. netFIELD App IO-Link Configurator 1.0.2
#
# The script utilizes the docker-compose tool to define and manage the multi-container 
# setup. When run without any additional argument, it installs and starts the containers. 
# If executed with the 'down' argument, the script stops the running container setup.
#
# During the setup, the script automatically generates a docker-compose-xxx.yml file 
# in the current directory the script was executed. You can use this file later 
# for your own customizations and configurations.
#
# Ensure that if you use script files from a different version in the future, you first 
# run the current script with the 'down' command before proceeding.


# create the docker-compose yml-file first
echo -e 'version: "2"\n'\
'services:\n'\
' mosquitto:\n'\
'   image: "eclipse-mosquitto:1.6.8"\n'\
'   container_name: "mosquitto"\n'\
'   restart: "always"\n'\
'   ports:\n'\
'     - "1883:1883/tcp"\n'\
'   networks:\n'\
'     sensoredge:\n'\
'       ipv4_address: 10.5.0.2\n'\
' netfield-app-opc-ua-io-link-adapter:\n'\
'   image: "hilschernetiotedge/sensoredgefield.basiccontainers:netfield-app-opc-ua-io-link-adapter-1.0.2-build.19"\n'\
'   container_name: "netfield-app-opc-ua-io-link-adapter"\n'\
'   restart: "always"\n'\
'   environment:\n'\
'     - "MONITOR_SUBNET=192.168.0.2/32"\n'\
'   volumes:\n'\
'     - "/sys/device_data/:/etc/device_data:ro"\n'\
'     - "netfield-app-opc-ua-io-link-adapter:/tmp/netfield-app-opc-ua-io-link-adapter"\n'\
'   networks:\n'\
'     sensoredge:\n'\
'       ipv4_address: 10.5.0.3\n'\
' netfield-app-io-link-configurator:\n'\
'   image: "hilschernetiotedge/sensoredgefield.basiccontainers:netfield-app-io-link-configurator-1.0.2-build.13"\n'\
'   container_name: "netfield-app-io-link-configurator"\n'\
'   restart: "always"\n'\
'   volumes:\n'\
'     - "/usr/local/share/cockpit:/usr/local/share/cockpit"\n'\
'     - "netfield-app-io-link-configurator:/tmp/netfield-app-io-link-configurator"\n'\
'   networks:\n'\
'     sensoredge:\n'\
'       ipv4_address: 10.5.0.4\n'\
'volumes:\n'\
'  netfield-app-opc-ua-io-link-adapter:\n'\
'    name: netfield-app-opc-ua-io-link-adapter\n'\
'  netfield-app-io-link-configurator:\n'\
'    name: netfield-app-io-link-configurator\n'\
'networks:\n'\
' sensoredge:\n'\
'  driver: bridge\n'\
'  ipam:\n'\
'    config:\n'\
'      - subnet: 10.5.0.0/16\n'\
> docker-compose-1.0.2.yml

# Check if a script argument was provided
if [ -z "$1" ]
then
  # without an agrument just start the yml-file with docker-compose 
  docker-compose -f docker-compose-1.0.2.yml up -d
else
  # else use the argument as parameter for the docker-compose command
  docker-compose -f docker-compose-1.0.2.yml $1
fi


