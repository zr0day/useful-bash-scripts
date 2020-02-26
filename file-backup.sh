#!/bin/bash

#
# Bash script for creating backups of Directorys.
#
# Version 1.1.0
#
# Usage:
#       - With backup directory specified in the script:  ./file-backup.sh
#       - With backup directory specified by parameter: ./file-backup.sh <BackupDirectory>
#
# IMPORTANT
# You have to customize this script (directories, users, etc.) for your actual environment.
# All entries which need to be customized are tagged with "TODO".
#

# Variables
backupMainDir=$1

if [ -z "$backupMainDir" ]; then
    backupMainDir='/'
fi

currentDate=$(date +"%Y%m%d_%H%M%S")

backupSourceDir=$2
if [ -z "$backupSourceDir" ]; then
    backupSourceDir='/mnt/backup/'
fi

# The actual directory of the current backup - this is a subdirectory of the main directory above with a timestamp
backupdir="${backupMainDir}/${currentDate}/"



# TODO: The maximum number of backups to keep (when set to 0, all backups are kept)
maxNrOfBackups=8


# File names for backup files
fileNameBackupFileDir="${backupMainDir}"

# Function for error messages
errorecho() { cat <<< "$@" 1>&2; }

#
# Print information
#
echo "Backup directory: ${backupMainDir}"

#
# Check for root
#
if [ "$(id -u)" != "0" ]
then
        errorecho "ERROR: This script has to be run as root!"
        exit 1
fi

#
# Check if backup dir already exists
#
if [ ! -d "${backupdir}" ]
then
        mkdir -p "${backupdir}"
else
        errorecho "ERROR: The backup directory ${backupdir} already exists!"
        exit 1
fi

#
# Backup data directory
#
echo "Creating backup of ${backupSourceDir} directory..."

if [ "$ignoreUpdaterBackups" = true ] ; then
        echo "Ignoring updater backup directory"
        tar -cpzf "${backupdir}/${fileNameBackupDataDir}"  -C "${backupSourceDir}" .
else
        tar -cpzf "${backupdir}/${fileNameBackupDataDir}"  -C "${backupSourceDir}" .
fi

echo "Done"
echo

#
# Delete old backups
#
if [ ${maxNrOfBackups} != 0 ]
then
        nrOfBackups=$(ls -l ${backupMainDir} | grep -c ^d)

        if [[ ${nrOfBackups} > ${maxNrOfBackups} ]]
        then
                echo "Removing old backups..."
                ls -t ${backupMainDir} | tail -$(( nrOfBackups - maxNrOfBackups )) | while read -r dirToRemove; do
                        echo "${dirToRemove}"
                        rm -r "${backupMainDir}/${dirToRemove:?}"
                        echo "Done"
                        echo
                done
        fi
fi

echo
echo "DONE!"
echo "Backup created: ${backupdir}"
