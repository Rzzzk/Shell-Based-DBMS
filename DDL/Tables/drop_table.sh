#! /usr/bin/bash


# get the current database path
current_db=${1}
echo "create table in << ${current_db} >> database"

# ask the user for the table name
#read -p "Enter the name of the table to drop: " table_name
table_name=$(zenity --entry --title="Drop Table" --text="Enter the name of the table to drop: ")

echo ${current_db}/tables/${table_name}
# check if the table already exists
if [ -f "${current_db}/tables/${table_name}" ]
then
    # drop the table file
    rm "${current_db}/tables/${table_name}"
    rm "${current_db}/metadata/${table_name}_meta"
    echo "Table '$table_name' dropped successfully from database."
    zenity --info --title="Drop Table" --text="dropped successfully from database."
else
    # table does not exist
    echo "Table '$table_name' does not exist in database."
    zenity --info --title="Drop Table" --text="Table '$table_name' does not exist in database."
fi
