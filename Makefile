.DEFAULT_GOAL := monitor

monitor: pull battery

pull:
	git pull

battery:
	sudo su -c './battery.sh'
