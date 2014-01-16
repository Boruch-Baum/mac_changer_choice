mac_changer_choice
==================

bash shell script and associated data file to generate a
randomized mac-address from selected survey parameters or
from the list of known vendor IDs

####USAGE:
<pre>
           macchanger_choice.sh interface [ option | search_string ]
              interface      eg. wlan0, eth0
              search_string  eg. tablet, laptop, lenovo, mac\n\
              option         currently, just 'ouilist'
</pre>

### Escalated Privileges Required:###
This script will invoke 'ifconfig interface [down|up]' and 'macchanger -m',
commands typically restricted to system administration roles.</dd>
###Requirements:
macchanger [https://github.com/alobbs/macchanger](https://github.com/alobbs/macchanger)

Your distribution may already have macchanger pre-packaged:

* debian: [http://packages.debian.org/search?keywords=macchanger&searchon=names&suite=all&section=all&sourceid=mozilla-search](http://packages.debian.org/search?keywords=macchanger&searchon=names&suite=all&section=all&sourceid=mozilla-search)

* fedora: [https://apps.fedoraproject.org/packages/macchanger?_csrf_token=9a050bd93266c1f81066a9da6a864f0f5f18093d](https://apps.fedoraproject.org/packages/macchanger?_csrf_token=9a050bd93266c1f81066a9da6a864f0f5f18093d)

### Files:
* macchanger_choice.sh - this executable file

* mac_address_survey.output - the data file

* OUI.list - a version of the IEEE list possibly newer than that used by macchanger.

### Compatability
This script has been tested in debian.

DESCRIPTION:
------------
Let a user easily select from among known mac vendor
   strings based upon hardware product device type,
   manufacturer, product name, or even model number.

   Alternatively, randomly select an entry from the OUI list
   bundled with 'maccchanger'.

ADVANTAGES:
-----------
<pre>
   1] Avoid assigning 'impossible' or 'implausible' addresses
   1.1] Because the vendor code has not yet been assigned
   1.2] Because the vendor code has been assigned to a
        manufacturer of a device/product incompatible with
        your use case.
   2] Convenient selection of surveyed vendor codes
   2.1] Within the script, one can scroll through the
        surveyed list and make a selection.
   2.2] Have the script randomly select a vendor code from
        among survey entries that match a grep search string
        eg. "lAPtoP", "samSUNg", "vaio"
   2.3] The surveyed list is small, but represents products
        commonly available for retail sale at the time of
        the survey (2014-01).
   2.4] Users can manually customize and add to their copy
        of the survey.
</pre>

DISCUSSION:
-----------
If one of your goals in using a random mac address is
   to emulate some random existing device, then using a
   truly random assignment will not meet your requirement
   because many(most?) of the vendor strings have not
   been assigned, and many of the possible numbers may
   never be assigned because two of the twenty-four bits
   are reserved (see below). This script will only
   generate 48-bit mac addresses using valid and assigned
   24-bit vendor IDs. For this, run

      macchanger_choice.sh <interface> ouilist

   If one of your goals in using a random mac address is
   to emulate some category of device, then using a
   random assignment, even from the set of known assigned
   24-bit vendors IDs,  will not meet your requirement,
   because a particular vendor may only manufacture
   hardware incompatible with your use case. For this, run

      macchanger_choice.sh <interface> <search string>

   This will generate and assign a random mac address from
   entries in the 'mac_address_survey' file that match
   your criteria. The sample survey file has 48 entries,
   all for interface wlan. Most entries are for laptops;
   some are for tablets. The search string need not be
   case-sensitive.

   If you would like to browse the survey data, and
   interactively choose from among the selected vendor
   strings, run

         macchanger_choice.sh <interface>

   Collecting the data for the sample survey file was
   the major effort of this project. The data file is
   columnated, space delimited  text file, with the
   following fields:

          Interface             (eg wlan, eth)
          Product Type          (eg laptop, tablet)
          Product Manufacturer  (eg Dell, Sony)
          Product Name          (eg Inspiron, Vaio)
          Product Model #       (eg 1545, SVF_13N13_CXB)
          24-bit MAC address vendor OUI string

   Users are encouraged to add their own survey
   entries to meet their own requirements.

   The survey information was originally recorded
   in a .ods format spreadsheet (along with other data),
   saved as csv, and reformatted using:
<pre>     sort ./mac_address_survey.csv | \
      awk -v FS="," 'BEGIN{getline}  \
             { gsub(" ","_"); gsub(",,",",_,"); \
               $7="";$8="";$9=""; \
               printf "%d %s\n",NR,$0; }' | \
      column -t \
      > mac_address_survey.output
</pre>
DETAILS OF THE 24-BIT FORMAT
----------------------------
The lowest two significant digits of the first octet
    (called octet 0) are reserved and in practice should
    always be set to zero. Bit 0 is referred to as the M
    bit, and bit 1 is referred to as the X bit. Per
    reference [1],  "all OUI assignments made by the
    IEEE RA have M and X bits equal to zero" and "M=1 is
    not currently assigned". See there for information of
    the two instances in which the X bit would be one: a
    CID; or "A very small number of assignments made
    prior to adoption of IEEE 802 standards"

#### 00:00:00:00:00:00
IEEE[1] demands that this MAC address value never be used

#### ff:ff:ff:ff:ff:ff
IEEE[1] recommends this value be used for a distinct null identifier, most often indicating the absence of a valid EUI-48

MAKE YOUR OWN OUI.list
----------------------
Both macchanger and this script use the IEEE data file,
available at DOUBLE CHECK THIS LINK 

<pre>
    http://standards.ieee.org/develop/regauth/oui/oui.txt
</pre>

The IEEE says it updates this list daily as new vendor
vendor IDs are assigned.

The list can be converted into the format used by
macchanger and by this script,  as follows:
<pre>
    awk '$0 ~ "(hex)"{$2="";gsub("-"," ");print}' \
        oui.txt > OUI.list 
</pre>

REFERENCES
----------
[1] IEEE FAQs: The Registration Authority [http://standards.ieee.org/faqs/regauth.html](http://standards.ieee.org/faqs/regauth.html)

[2] IEEE Guidelines for Use: Organizationally Unique Identifier
(OUI) and Company ID (CID) [http://standards.ieee.org/develop/regauth/tut/eui.pdf](http://standards.ieee.org/develop/regauth/tut/eui.pdf)

Author:
-------
Boruch Baum <boruch_baum@gmx.com>

Copyright (C) 2014, Boruch Baum

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 3
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
USA
