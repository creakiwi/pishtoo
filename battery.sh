#!/bin/sh

# Ensure the script is run as root
if [ $(id -u) -ne 0 ]
then
  echo "This script must be run as root. Try: sudo $0"
  exit 1
fi

ITERATION=0
SLEEP=10
MANUFACTURER=$(dmidecode -s system-manufacturer)
PRODUCT_NAME=$(dmidecode -s system-product-name)
SERIAL_NUMBER=$(dmidecode -s system-serial-number)
VERSION=$(dmidecode -s system-version)
UNAME=$(head -n1 /etc/issue | sed 's/\\.*//')

monitor_send_data() {
	DATA=${1}
	VALUE=${2}
	ENDPOINT="https://creakiwi.com/monitor/${SERIAL_NUMBER}/${DATA}/${VALUE}"
	curl -s --fail ${ENDPOINT}
	echo "${DATA}: ${VALUE}"
}


monitor() {
	BAT=$(upower -e |grep "battery")
	BAT_CAPACITY_PERCENT=$(upower -i ${BAT} | grep "capacity" | awk '{print $2}' | tr -d '%')
	BAT_CURRENT_PERCENT=$(upower -i ${BAT} | grep "percentage" | awk '{print $2}' | tr -d '%')
	BAT_TIME_UNTIL_OFF=$(upower -i ${BAT} | grep "time to empty" | awk '{print $4$5}')
	BAT_TIME_UNTIL_100=$(upower -i ${BAT} | grep "time to full" | awk '{print $4$5}')

	echo "Machine: ${MANUFACTURER} ${PRODUCT_NAME} (sn: ${SERIAL_NUMBER})"
	echo "OS: ${UNAME}"
	monitor_send_data "max_capacity_percent" ${BAT_CAPACITY_PERCENT}
	monitor_send_data "current_capacity_percent" ${BAT_CURRENT_PERCENT}
	monitor_send_data "time_to_poweroff" ${BAT_TIME_UNTIL_OFF}
	monitor_send_data "time_to_full" ${BAT_TIME_UNTIL_100}
	monitor_send_data "iteration" ${ITERATION}
	monitor_send_data "sleep" ${SLEEP}

	ITERATION=$((ITERATION+1))
	sleep ${SLEEP}
}

while true
do
	monitor
done
