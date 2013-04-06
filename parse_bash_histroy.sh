#!/bin/bash
#
# DESCRIPTION
# ===========
# Parse bash history and email script.
# 
# Author  : Greg Colley
# Date    : 06.04.2013
# Version : 1.0

# SETUP 
# =====
# To setup your bash_history file to log timestamps, you need to set one environment variable HISTTIMEFORMAT. 
#
# The HISTTIMEFORMAT variable needs to be added to your bashrc scripts. It's recommended to add system wide
#
# To do this type the following line into the /etc/bash.bashrc (Ubuntu system)
#  export HISTTIMEFORMAT="%F %T "
#
# This way the timestamps are saved directly above each command in the ~/.bash_history file after you exit the shell
# 
# Please note some systems may already be configured to have timestamps on the bash_history file.
#

# REQUIREMENTS
# ===========
# bc is required for the elapsed time calculation of the script, you can comment out this if you do to wish to use it
# mail - mail is required for sending emails

# CONFIGURATION
# =============
# If you need to change the location of the .bahs_history file then modify the line below
filename='/root/.bash_history'

# Email to address
EMAIL_TO='email@xrmx.co.uk'

# Email subject 
EMAIL_SUBJECT='Bash History'

##################################################################
# Do not edit the lines below unless you know what you are doing #
##################################################################

# Define variables we will be using
datestamp=`date +%c`
lognextline='0'
lineslogged=0
SCRIPTPATH=`dirname $0`
since_id=`cat ${SCRIPTPATH}/since_id`

# Start timing
res1=$(date +%s.%N)

# Empty the mailfile
echo "Bash history for ${datestamp}" > ${SCRIPTPATH}/mailfile
echo "" >> ${SCRIPTPATH}/mailfile

# Loop around all of the lines in the bash_history file
while read line; do

	# Check if we are logging the line (assuming all timestamps are before commands)
	if [[ "$lognextline" == '1' ]]; then
		
		# Output the line to the file we will mail
		echo "`date -d @$timestamp +%c` - $line" >> ${SCRIPTPATH}/mailfile
                # reset the lognextline flag so we can check if it's a timestamp again
		lognextline='0'
		# increment the counter so we know how many lines have been logged
		lineslogged=lineslogged+1
   	else
		# Check if the command has a # at the beginning (assumed it's a timestamp)
		tmpstring=${line:0:1}
     		if [[ "$tmpstring" == '#' ]]; then 
           		
			# Get the timestamp 
			timestamp=${line:1:11}
			
			# Check if we want to log this line as we are only interested in command after the  
			if [[ "$timestamp" > "$since_id" ]]; then 
				lognextline='1'
			fi
    		fi
   	fi
done < $filename

if [ "$lineslogged" == '0' ]; then 
	echo "No new commands have been executed by the root user." >> ${SCRIPTPATH}/mailfile
fi 
# Save the timestamp so we know where we left off
echo $timestamp > ${SCRIPTPATH}/since_id

# End timing
res2=$(date +%s.%N)


# Email signature
echo "" >> ${SCRIPTPATH}/mailfile
echo "--" >> ${SCRIPTPATH}/mailfile
echo "parse_bash_history.sh" >> ${SCRIPTPATH}/mailfile
echo "Script Execution time $(echo "$res2 - $res1"|bc )" >> ${SCRIPTPATH}/mailfile

# Mail the file to the admin for a audit log of all bash_history commands
cat ${SCRIPTPATH}/mailfile | mail -s "${EMAIL_SUBJECT}" ${EMAIL_TO}

# Remove the temp mailfile to keep things clean
rm ${SCRIPTPATH}/mailfile
