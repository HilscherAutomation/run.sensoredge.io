#!/bin/sh
set -e

version=1.3.0
composefile=docker-compose-$version.yml

echo Basic container installer script for sensorEDGE FIELD devices in the version V$version
echo ===================================================================================
echo
echo Copyright 2025, Hilscher Gesellschaft fuer Systemautomation mbH
echo Licensed under the MIT license
echo
echo This script is intended as a convenient way to setup a sensorEDGE FIELD device with 
echo its necessary software packed in containers. 
echo
echo The containers that are installed by this script include:
echo
echo 1. Eclipse mosquitto 1.6.8
echo 2. netFIELD App IO-Link Adapter 1.3.0
echo 3. netFIELD App IO-Link Configurator 1.3.0
echo
echo The script utilizes the docker-compose tool to define and manage the multi-container 
echo setup. When run without any additional argument, it installs and starts the containers. 
echo If executed with the 'down' argument, the script stops the running container setup.
echo
echo During the setup, the script automatically generates a $composefile file 
echo in the current directory the script was executed. You can use this file later 
echo for your own customizations and configurations.
echo
echo Ensure that if you use script files from a different version in the future, you first 
echo run the current script with the 'down' command before proceeding to shut down running
echo containers.
echo
echo The script runs the Eclipse Mosquitto container application without exposing port 1883.
echo To expose the port, simply remove the '#' symbol from the lines
echo   \# ports:
echo   \# - "1883:1883/tcp" 
echo in the the created $composefile file. If needed, you can also change the 
echo external port 1883 to any port of your choice.
echo

# create the docker-compose file

echo -e 'version: "2"\n'\
'services:\n'\
' mosquitto:\n'\
'   image: "eclipse-mosquitto:1.6.8"\n'\
'   container_name: "mosquitto"\n'\
'   restart: "always"\n'\
'#   ports:\n'\
'#     - "1883:1883/tcp"\n'\
'   networks:\n'\
'     sensoredge:\n'\
'       ipv4_address: 10.5.0.2\n'\
' netfield-app-opc-ua-io-link-adapter:\n'\
'   image: "docker.io/hilscherautomation/netfield-app-opc-ua-io-link-adapter:1.3.0"\n'\
'   container_name: "netfield-app-opc-ua-io-link-adapter"\n'\
'   restart: "always"\n'\
'   volumes:\n'\
'     - "/etc/gateway/settings.json:/etc/gateway/settings.json:ro"\n'\
'     - "/etc/gateway/mqtt-config.json:/etc/gateway/mqtt-config.json:ro"\n'\
'     - "/usr/local/share/cockpit:/usr/local/share/cockpit"\n'\
'     - "/var/platform/device_data:/app/configdata/device_data"\n'\
'     - "netfield-app-opc-ua-io-link-adapter:/opt/oi4/app"\n'\
'   networks:\n'\
'     sensoredge:\n'\
'       ipv4_address: 10.5.0.3\n'\
' netfield-app-io-link-configurator:\n'\
'   image: "docker.io/hilscherautomation/netfield-app-io-link-configurator:1.3.0"\n'\
'   container_name: "netfield-app-io-link-configurator"\n'\
'   restart: "always"\n'\
'   volumes:\n'\
'     - "/etc/gateway/settings.json:/etc/gateway/settings.json:ro"\n'\
'     - "/etc/gateway/mqtt-config.json:/etc/gateway/mqtt-config.json:ro"\n'\
'     - "/usr/local/share/cockpit:/usr/local/share/cockpit"\n'\
'     - "/var/platform/device_data:/app/configdata/device_data"\n'\
'     - "netfield-app-io-link-configurator:/opt/oi4/app"\n'\
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
> $composefile

# Check if a script argument was provided
if [ -z "$1" ]
then
  # without an argument just start the yml-file with docker-compose 
  docker-compose -f $composefile up -d
else
  # else use the argument as parameter for the docker-compose command
  docker-compose -f $composefile $1
fi


