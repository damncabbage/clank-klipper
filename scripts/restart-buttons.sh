#!/usr/bin/env bash

set -e
set -u
set -o pipefail

: ${DEBUG:=}

debug() {
	if [ ! -z "$DEBUG" ]; then
		>&2 echo "++ $@"
	fi
}

button_pressed() {
	local res
	res=$(sudo /usr/bin/gpioget --active-low --bias pull-up gpiochip0 "$1")
	[ "$res" == "1" ]
}

send_klipper_command() {
	debug "$ echo $1 >> /tmp/printer"
	echo "$1" >> /tmp/printer
}

: ${SLEEP_LENGTH:=2}
: ${PRESS_ITERATIONS:=2}

# Pins for buttons; 63 and 64 is Pin 3 and 5 respectively. See:
#   $ sudo grep GPIOA /sys/kernel/debug/pinctrl/ff634400.bus:pinctrl@40-pinctrl-meson/pinconf-pins
#   pin 63 (GPIOA_14): input bias pull up (1 ohms), output drive strength (3000 uA)
#   pin 64 (GPIOA_15): input bias pull up (1 ohms), output drive strength (3000 uA)

: ${KLIPPER_RESTART_PIN:=63} # GPIOA_14
: ${FIRMWARE_RESTART_PIN:=64} # GPIOA_15

KLIPPER_RESTART_PRESS_COUNT=0
FIRMWARE_RESTART_PRESS_COUNT=0

while true; do
	debug "KLIPPER_RESTART: $(button_pressed "$KLIPPER_RESTART_PIN" && echo "pressed" || echo "-")"
	debug "FIRMWARE_RESTART: $(button_pressed "$FIRMWARE_RESTART_PIN" && echo "pressed" || echo "-")"

	if button_pressed "$KLIPPER_RESTART_PIN"; then
		KLIPPER_RESTART_PRESS_COUNT=$((KLIPPER_RESTART_PRESS_COUNT + 1))
		if [ "$KLIPPER_RESTART_PRESS_COUNT" -ge "$PRESS_ITERATIONS" ]; then
			send_klipper_command "RESTART"
			echo "Klipper Restart initiated..."
			KLIPPER_RESTART_PRESS_COUNT=0
		fi
	else
		KLIPPER_RESTART_PRESS_COUNT=0
	fi
		
	if button_pressed "$FIRMWARE_RESTART_PIN"; then
		FIRMWARE_RESTART_PRESS_COUNT=$((FIRMWARE_RESTART_PRESS_COUNT + 1))
		if [ "$FIRMWARE_RESTART_PRESS_COUNT" -ge "$PRESS_ITERATIONS" ]; then
			send_klipper_command "FIRMWARE_RESTART"
			echo "Firmware Restart initiated..."
			FIRMWARE_RESTART_PRESS_COUNT=0
		fi
	else
		FIRMWARE_RESTART_PRESS_COUNT=0
	fi

	sleep "$SLEEP_LENGTH"
done
