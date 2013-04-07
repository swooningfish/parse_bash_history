#!/bin/bash
#
# DESCRIPTION
# ===========
# Parse bash history and email script.
# 
# Author  : Greg Colley
# Date    : 06.04.2013
# Version : 1.3

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

# USAGE
# =====
# To use this script type './parse_bash_history.sh email@address.com' 

# CONFIGURATION
# =============

# Location of the bash_history file you wish to parse
FILENAME='/root/.bash_history'

# Email subject 
EMAIL_SUBJECT='Bash History'

##################################################################
# Do not edit the lines below unless you know what you are doing #
##################################################################

E_NO_ARGS=65

if [ $# -eq 0 ]  	# Must have command-line args to create the reposotry.
then
	echo "  __________________________________________"
	echo "  You must specify email address to send to "
	echo "  e.g. "
	echo "  ./parse_bash_histroy.sh name@domain.com"
	echo "  __________________________________________"
	exit $E_NO_ARGS
fi

if [[ "$1" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$ ]]
then
    echo "Email address looks valid"
    # Set the param to the email_to variable
    EMAIL_TO=$1
else
    echo "Invalid email address, please check and try again"
    exit 0
fi

# Define variables we will be using
HOST_NAME=`hostname`
DATE_STAMP=`date +%c`
LOG_NEXT_LINE='0'
TIME_STAMP=0
LINES_LOGGED=0
SCRIPTPATH=`dirname $0`
SINCE_ID=`cat ${SCRIPTPATH}/since_id`
TMP_STRING='';

# Start timing
TIME1=$(date +%s.%N)

# Empty the mailfile
echo "Bash history for ${HOST_NAME} at ${DATE_STAMP}" > ${SCRIPTPATH}/mailfile
echo "" >> ${SCRIPTPATH}/mailfile

# Loop around all of the lines in the bash_history file
while read LINE 
do
	# Check if we are logging the line (assuming all timestamps are before commands)
	if [[ "$LOG_NEXT_LINE" == '1' ]]
	then
		# Output the line to the file we will mail
		echo "`date -d @$TIME_STAMP +%c` - $LINE" >> ${SCRIPTPATH}/mailfile
        
		# reset the LOG_NEXT_LINE flag so we can check if it's a timestamp again
		LOG_NEXT_LINE='0'

		# increment the counter so we know how many lines have been logged
		let LINES_LOGGED=LINES_LOGGED+1
   	else
		# Check if the command has a # at the beginning (assumed it's a timestamp)
		TMP_STRING=${LINE:0:1}
 		if [[ "$TMP_STRING" == '#' ]]
		then 
			# Get the time stamp 
			TIME_STAMP=${LINE:1:11}
			
			# Check if we want to log this line as we are only interested in command after the  
			if [[ "$TIME_STAMP" > "$SINCE_ID" ]]
			then 
				LOG_NEXT_LINE='1'
			fi
		fi
   	fi
done < $FILENAME

# Only email if we need to
echo "Lines Logged = $LINES_LOGGED"
if [ $LINES_LOGGED != 0 ]
then 

	# End timing
	TIME2=$(date +%s.%N)

	# Email signature
	echo "" >> ${SCRIPTPATH}/mailfile
	echo "--" >> ${SCRIPTPATH}/mailfile
	echo "parse_bash_history.sh" >> ${SCRIPTPATH}/mailfile
	echo "Script Execution time $(echo "$TIME1 - $TIME2"|bc )" >> ${SCRIPTPATH}/mailfile

	# Mail the file to the admin for a audit log of all bash_history commands
	cat ${SCRIPTPATH}/mailfile | mail -s "${EMAIL_SUBJECT}" ${EMAIL_TO}

else
	echo "Nothing to email";
fi

# Save the timestamp so we know where we left off
echo $TIME_STAMP > ${SCRIPTPATH}/since_id

# Remove the temp mailfile to keep things clean
rm ${SCRIPTPATH}/mailfile
