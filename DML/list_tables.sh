#! /usr/bin/bash

# get the current database path
current_db=${1}
echo "list the tables of << ${current_db} >> database"

# list the tables in the current database
ls -1 "${current_db}/tables"
echo "------------------"