#!/bin/bash
#--------------------------------------------------------------
#
# bash shell script and associated data file to generate a
# randomized mac-addreGenerate a randomized mac-address from
# selected survey parameters or from the list of known vendor IDs
#
# USAGE: macchanger_choice.sh interface [ option | search_string ]
#    interface      eg. wlan0, eth0
#    search_string  eg. tablet, laptop, lenovo, mac\n\
#    option         currently, just 'ouilist'
#
# Escalated Privileges Required: This script will invoke
#    'ifconfig interface [down|up]' and 'macchanger -m',
#    commands typically restricted to system administration roles. 
#
# Requirements: macchanger(https://github.com/alobbs/macchanger).
#    Your distribution may already have macchanger pre-packaged.
#
# Files:
#    macchanger_choice.sh - this executable file
#    mac_address_survey.output - the data file
#    OUI.list - a version of the IEEE list possibly newer than
#       that used by macchanger.
#
# Compatability: tested and works in debian
#
# DESCRIPTION:
#    Let a user easily select from among known mac vendor
#    strings based upon hardware product device type,
#    manufacturer, product name, or even model number.
#
#    Alternatively, randomly select an entry from the OUI list
#    bundled with 'maccchanger'.
#
# ADVANTAGES:
#    1] Avoid assigning 'impossible' or 'implausible' addresses
#    1.1] Because the vendor code has not yet been assigned
#    1.2] Because the vendor code has been assigned to a
#         manufacturer of a device/product incompatible with
#         your use case.
#    2] Convenient selection of surveyed vendor codes
#    2.1] Within the script, one can scroll through the
#         surveyed list and make a selection.
#    2.2] Have the script randomly select a vendor code from
#         among survey entries that match a grep search string
#         eg. "lAPtoP", "samSUNg", "vaio"
#    2.3] The surveyed list is small, but represents products
#         commonly available for retail sale at the time of
#         the survey (2014-01).
#    2.4] Users can manually customize and add to their copy
#         of the survey.
#
# DISCUSSION:
#    If one of your goals in using a random mac address is
#    to emulate some random existing device, then using a
#    truly random assignment will not meet your requirement
#    because many(most?) of the vendor strings have not 
#    been assigned, and many of the possible numbers may
#    never be assigned because two of the twenty-four bits
#    are reserved (see below). This script will only 
#    generate 48-bit mac addresses using valid and assigned
#    24-bit vendor IDs. For this, run
#
#       macchanger_choice.sh <interface> ouilist
#
#    If one of your goals in using a random mac address is
#    to emulate some category of device, then using a
#    random assignment, even from the set of known assigned
#    24-bit vendors IDs,  will not meet your requirement,
#    because a particular vendor may only manufacture
#    hardware incompatible with your use case. For this, run
#
#       macchanger_choice.sh <interface> <search string>
#
#    This will generate and assign a random mac address from
#    entries in the 'mac_address_survey' file that match
#    your criteria. The sample survey file has 48 entries,
#    all for interface wlan. Most entries are for laptops;
#    some are for tablets. The search string need not be
#    case-sensitive.
#
#    If you would like to browse the survey data, and 
#    interactively choose from among the selected vendor
#    strings, run
#
#          macchanger_choice.sh <interface>
#
#    Collecting the data for the sample survey file was
#    the major effort of this project. The data file is
#    columnated, space delimited  text file, with the
#    following fields:
#
#	  Interface             (eg wlan, eth)
#	  Product Type          (eg laptop, tablet)
#	  Product Manufacturer  (eg Dell, Sony)
#	  Product Name          (eg Inspiron, Vaio)
#	  Product Model #       (eg 1545, SVF_13N13_CXB)
#	  24-bit MAC address vendor OUI string
#
#    Users are encouraged to add their own survey
#    entries to meet their own requirements.
#
#    The survey information was originally recorded
#    in a .ods format spreadsheet (along with other data),
#    saved as csv, and reformatted using:
#      sort ./mac_address_survey.csv | \
#       awk -v FS="," 'BEGIN{getline}  \
#              { gsub(" ","_"); gsub(",,",",_,"); \
#                $7="";$8="";$9=""; \
#                printf "%d %s\n",NR,$0; }' | \
#       column -t \
#       > mac_address_survey.output
#
# DETAILS OF THE 24-BIT FORMAT
#     The lowest two significant digits of the first octet
#     (called octet 0) are reserved and in practice should
#     always be set to zero. Bit 0 is referred to as the M
#     bit, and bit 1 is referred to as the X bit. Per
#     reference [1],  "all OUI assignments made by the
#     IEEE RA have M and X bits equal to zero" and "M=1 is
#     not currently assigned". See there for information of
#     the two instances in which the X bit would be one: a
#     CID; or "A very small number of assignments made
#     prior to adoption of IEEE 802 standards"
#
# 00:00:00:00:00:00
#     IEEE[1] demands that this MAC address value never be used
#
# ff:ff:ff:ff:ff:ff
#     IEEE[1] recommends this value be used for a distinct null
#     identifier, most often indicating the absence of a
#     valid EUI-48
#
# MAKE YOUR OWN OUI.list
#     Both macchanger and this script use the IEEE data file,
#     available at DOUBLE CHECK THIS LINK 
#
#     http://standards.ieee.org/develop/regauth/oui/oui.txt
#
#     The IEEE says it updates this list daily as new vendor
#     vendor IDs are assigned.
#
#     The list can be converted into the format used by
#     macchanger and by this script,  as follows:
#
#     awk '$0 ~ "(hex)"{$2="";gsub("-"," ");print}' \
#         oui.txt > OUI.list 
#
# REFERENCES
#    [1] http://standards.ieee.org/faqs/regauth.html
#    [2] http://standards.ieee.org/develop/regauth/tut/eui.pdf
#
# Author:
#      Boruch Baum <boruch_baum@gmx.com>
# 
# Copyright (C) 2014, Boruch Baum
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
# USA
# 
#--------------------------------------------------------------

# This following absolute pathname is the default install
# path in debian, and may be different in you operating
# environment
ouilist_absolute_file_name="/usr/share/macchanger/OUI.list"
# This next should be the path of the version of the oui list
# packaged with this script
ouilist_local_file_name="./OUI.list"

data_file="./mac_address_survey.output"

# ERROR CODES
INTERFACE_NOT_SUPPLIED=1
TOO_MANY_PARAMETERS=2
PATTERN_MATCH_NOT_FOUND=3
INVALID_INTERFACE_NAME=4
IFCONFIG_DOWN_UNSUCCESSFUL=5
MACCHANGER_M_UNSUCESSFUL=6
OUI_LIST_NOT_FOUND=7

function usage_message()
{
printf "USAGE: macchanger_choice.sh interface [ option | search_string ]\n\
    interface      eg. wlan0, eth0\n\
    option         currently, just 'ouilist'\n\
    search_string  eg. tablet, lAptOp, Lenovo, mac\n"
}


function finalize_random_choice()
{
[[ ( ${new_mac_string} == "00:00:00:00:00:00" ) ]] \
&& new_mac_string="00:00:00:00:00:01"
# ff:ff:ff:ff:ff:ff does not need to tested for
# because the IEEE says it will never issue the
# ff:ff:ff vendor string
printf "new mac string will be: %s\n" ${new_mac_string}
}


function manually_choose_mac()
{
line_num=0
message_1="Generate a randomized mac-address from a selected vendor\n\nAfter you press <return>, a selection will be displayed in\na 'less' browser, prefixed by a line number. When you have chosen\nyour desired response, enter q to quit less, and at the next prompt\nenter your desired response's line number, or Ctrl-C to abort."
message_2="enter line number of desired entry; Ctrl-C to abort: "

echo -e ${message_1}
read
less -SFX ${data_file}
read -p "${message_2}" line_num
while !  [[ "${line_num}" =~ ^[0-9]*$ ]] \
      || [[ ${line_num} -eq 0 ]] ; do
   echo -e "error: response not a positive integer."
   read -p "${message_2}" line_num
   done

new_mac_string="$(awk -v line_num=${line_num} \    \
                  'NR==line_num{printf $7}' ${data_file})$(printf ':%02X:%02X:%02X' $(($RANDOM/256)) $(($RANDOM/256)) $(($RANDOM/256)) )"
finalize_random_choice
}


function grep_random_choose_mac()
{
find_count=$(grep -i -e "$1" ${data_file}|grep -ic -e "$2" ${data_file} )
if [[ ${find_count} == 0 ]] ; then
   printf "error: pattern to match %s was not found for interface %s\n",$1, $2
   exit ${PATTERN_MATCH_NOT_FOUND};
fi
line_count=$((($RANDOM%${find_count})+1))
awk_result=$(awk -v match_count=0 \
                 -v line_count=${line_count} \
                 -v srch1=${1} \
                 -v srch2=${2} \
                 -v IGNORECASE=1 \
                 '( srch1 ~ "$1?" ) && ($0 ~ srch2){match_count++; if (match_count==line_count){printf $0;exit}}' \
                 ${data_file})
awk_fields=(${awk_result})
printf "selected: %s %s %s model_#:%s\n" \
       ${awk_fields[2]} ${awk_fields[3]} ${awk_fields[4]} ${awk_fields[5]}
new_mac_string=${awk_fields[6]}$(printf ':%02X:%02X:%02X' $(($RANDOM%256)) $(($RANDOM%256)) $(($RANDOM%256)) )
finalize_random_choice
}


function ouilist_random_choose_mac()
{
if [[ -e ${ouilist_absolute_file_name} ]] ; then
   number_of_lines=$(wc -l < ${ouilist_absolute_file_name})
   if [[ -e ${ouilist_local_file_name} ]] ; then
      local_number_of_lines=$(wc -l < ${ouilist_local_file_name})
      if [[ ${local_number_of_lines} -gt ${number_of_lines} ]] ; then
         ouilist_absolute_file_name=${ouilist_local_file_name}
         printf "NOTE!: The macchanger_choice copy of the oui list seems to\n\
       be more comprehensive than the one bundled in macchanger\n\
       (%'d vs. %'d entries). We will use ours. You may \n\
       want to consider updating the macchanger copy\n\n" \
              ${local_number_of_lines} ${number_of_lines}
         number_of_lines=${local_number_of_lines}
      fi
   fi
elif [[ -e ${ouilist_local_file_name} ]] ; then
   number_of_lines=$(wc -l < ${ouilist_local_file_name})
   ouilist_absolute_file_name=${ouilist_local_file_name}
   # no error or warning. the macchanger ouilist
   # is probably just in a path I haven't checked
else
   printf "error: can not find oui list\n\
       mac address was not changed\n"
   exit ${OUI_LIST_NOT_FOUND}
fi
number_of_lines=$(wc -l < ${ouilist_absolute_file_name})
line_number_selected=$(( ($RANDOM%${number_of_lines})+1 ))
awk_result=$(awk -v line=${line_number_selected} \
                 'NR == line{printf $0"\n";exit}'\
                  ${ouilist_absolute_file_name})
awk_fields=(${awk_result})
printf "selected: %s\n" "${awk_result}"
new_mac_string=${awk_fields[0]}":"${awk_fields[1]}":"${awk_fields[2]}$(printf ':%02X:%02X:%02X' $(($RANDOM%256)) $(($RANDOM%256)) $(($RANDOM%256)) )
finalize_random_choice
}


function validate_interface()
{
interface_list=$(ip link show | \
 awk -v ORS=" " '$1 ~ "[1-9]*:"{if ($2=="lo:") next; gsub(":","",$2);print $2}')
for interface in $interface_list ; do
   if [[ $1 == ${interface} ]] ; then
      return
   fi
done
printf "error: invalid interface \"%s\" requested.\n\
       available interfaces are: %s\n" $1 "${interface_list}"
exit ${INVALID_INTERFACE_NAME}
}

#--------------------------------------------------------------
#
# MAIN - execution begins here
#
#--------------------------------------------------------------
if [[ $1 =~ ^(-)?(-)?(usage|help)$ ]] ; then
   usage_message;
   exit
fi

validate_interface $1

case $# in
1)  if [[ $1 == "ouilist" ]] ; then
       printf "error: you didn't tell me for which interface\n"
       usage_message;
       exit ${INTERFACE_NOT_SUPPLIED}
    else
       manually_choose_mac
    fi
    ;;
2)  if [[ $2 == "ouilist" ]] ; then
       ouilist_random_choose_mac
    else
       grep_random_choose_mac $1 $2
    fi
    ;;
*)  usage_message
    exit ${TOO_MANY_PARAMETERS}
    ;;
esac

ifconfig $1 down \
|| { printf "error: aborting. failed to ifconfig %s down,\n\
       mac address was not changed\n\
       Are you running this script with sudo?\n" $1; exit ${IFCONFIG_DOWN_UNSUCCESSFUL}; }
macchanger --mac=${new_mac_string} $1 \
|| { printf "error: command \"macchanger -m. %s\" failed,\n\
       mac address was not changed, interface %s is down\n" $1 $1; exit ${MACCHANGER_M_UNSUCCESSFUL}; }
ifconfig $1 up \
||   printf "error: failed to ifconfig %s up, but change\n\
       of mac address was successful\n" $1
