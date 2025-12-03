#! /usr/bin/bash

echo "---------------------------------------------"
echo "---  The tables of [${db_name}] database  ---"
echo "---------------------------------------------"
echo 
# list the tables in the current database
ls "${current_db}/tables"
echo
echo "-------------------------"

zenity --info  --text="
---------------------------------------------
---  The tables of [${db_name}] database  ---
---------------------------------------------

$(ls "${current_db}/tables")
-----------------------------
 "
