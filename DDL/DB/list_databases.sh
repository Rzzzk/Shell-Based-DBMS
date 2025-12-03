#! /usr/bin/bash

source ./config.sh


# list existing databases
echo "-------------------------"
echo "-- Existing Databases: --"
echo "-------------------------"
echo 
ls  $DATA_BASES_DIR
echo
echo "-------------------------"

# Get database list
db_list=$(ls "$DATA_BASES_DIR")

# Show in Zenity list
zenity --list \
  --title="Existing Databases" \
  --column="Databases" \
  $db_list

