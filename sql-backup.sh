#!/bin/bash

# Variables
currentDate=$(date +"%Y%m%d_%H%M%S")

# The actual directory of the current backup - this is a subdirectory of the main directory above with a timestamp
backupdir="${currentDate}/"

# TODO: The name of the database system (ome of: mysql, mariadb, postgresql)
databaseSystem='mariadb'

# TODO: Your database name
Database=''

# TODO: Your database user
dbUser=''

# TODO: The password of the database user
dbPassword=''

# TODO: The maximum number of backups to keep (when set to 0, all backups are kept)
maxNrOfBackups=8


fileNameBackupDb="${Database}-db.sql"

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
# Backup DB
#
if [ "${databaseSystem,,}" = "mysql" ] || [ "${databaseSystem,,}" = "mariadb" ]; then
        echo "Backup ${Database} database (MySQL/MariaDB)..."

        if ! [ -x "$(command -v mysqldump)" ]; then
                errorecho "ERROR: MySQL/MariaDB not installed (command mysqldump not found)."
                errorecho "ERROR: No backup of database possible!"
        else
                mysqldump --single-transaction -h localhost -u "${dbUser}" -p"${dbPassword}" "${Database}" > "${backupdir}/${fileNameBackupDb}"
        fi

        echo "Done"
        echo
elif [ "${databaseSystem,,}" = "postgresql" ]; then
        echo "Backup ${Database} database (MySQL/MariaDB)..."

        if ! [ -x "$(command -v pg_dump)" ]; then
                errorecho "ERROR:PostgreSQL not installed (command pg_dump not found)."
                errorecho "ERROR: No backup of database possible!"
        else
                PGPASSWORD="${dbPassword}" pg_dump "${Database}" -h localhost -U "${dbUser}" -f "${backupdir}/${fileNameBackupDb}"
        fi

        echo "Done"
        echo
fi

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
