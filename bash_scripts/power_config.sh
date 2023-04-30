#!/bin/bash

# Define escape codes for text formatting
BOLD_GREEN='\033[1;32m'
RESET='\033[0m'

# Check if Dell Command | Configure is installed
if [ -f /opt/dell/dcc/cctk ]; then
  echo "Dell Command | Configure Installed ✓"
else
  echo "Dell Command | Configure is not installed"
  exit 1
fi

# Check if script is run with root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run with sudo"
  exit 1
fi

if [ -z "$1" ]; then
  # No argument provided, display current settings
  echo -e "${BOLD_GREEN}Current power management settings:${RESET}"
  echo -e "${BOLD_GREEN}---------------------------------${RESET}"
  sudo /opt/dell/dcc/cctk --PrimaryBattChargeCfg
  sudo /opt/dell/dcc/cctk --PeakShiftCfg
  sudo /opt/dell/dcc/cctk --PeakShiftBatteryThreshold
else
  if [ "$1" == "plugged-in" ]; then
    # Plugged-in mode settings
    echo "Switching to plugged-in mode settings"
    sudo /opt/dell/dcc/cctk --PrimaryBattChargeCfg=PrimAcUse
    sudo /opt/dell/dcc/cctk --PeakShiftCfg=Disable
    sudo /opt/dell/dcc/cctk --PeakShiftBatteryThreshold=80
    sudo /opt/dell/dcc/cctk --PrimaryBattChargeCfg=custom:70-80
  elif [ "$1" == "travel" ]; then
    # Travel mode settings
    echo "Switching to travel mode settings"
    sudo /opt/dell/dcc/cctk --PrimaryBattChargeCfg=Adaptive
    sudo /opt/dell/dcc/cctk --PeakShiftCfg=Enable
    sudo /opt/dell/dcc/cctk --PeakShiftBatteryThreshold=60
    sudo /opt/dell/dcc/cctk --PrimaryBattChargeCfg=custom:50-80
  elif [ "$1" == "full-charge" ]; then
    # Full charge mode settings
    echo "Switching to full charge mode settings"
    sudo /opt/dell/dcc/cctk --PrimaryBattChargeCfg=Standard
    sudo /opt/dell/dcc/cctk --PeakShiftCfg=Disable
    sudo /opt/dell/dcc/cctk --PeakShiftBatteryThreshold=100
    sudo /opt/dell/dcc/cctk --PrimaryBattChargeCfg=custom:99-100
  elif [ "$1" == "battery" ]; then
    # Battery information
    echo -e "${BOLD_GREEN}Battery information:${RESET}"
    echo -e "${BOLD_GREEN}---------------------${RESET}"
    upower -i /org/freedesktop/UPower/devices/battery_BAT0
  else
    # Invalid argument
    echo "Invalid argument. Usage: ./power_config.sh [plugged-in|travel|full-charge|battery]"
    exit 1
  fi
fi
