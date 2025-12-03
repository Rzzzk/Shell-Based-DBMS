#! /usr/bin/bash

# source the configuration file
source ./config.sh

# Enable extended pattern
shopt -s extglob

echo "----------------------------"
echo "----- Creat Database  ------"
echo "----------------------------"
echo

# ask the user for the database name
db_name=""
#read -p "Enter the name of the database to create: " db_name
db_name=$(zenity --entry --title="Enter Database Name" --text="Enter the name of the database to create: ")

# check if the database name is accepted.
is_name_valid=$(./Helper_Scripts/name_validation.sh "$db_name")

# check is the name is valid or not
if [[ "${is_name_valid}" == "yes" ]]; then

    # check if the database already exists
    if [ -d "$DATA_BASES_DIR/$db_name" ]
    then
        echo "Database '$db_name' already exists."
        echo "Please choose a different name."
        echo
        echo "-------------------------"
        zenity --error --text="Database already exists"
    else
        # create the database directory
        mkdir -p "$DATA_BASES_DIR/$db_name/tables"
        mkdir -p "$DATA_BASES_DIR/$db_name/metadata"

        echo "Database '$db_name' created successfully."
        echo
        echo "-------------------------"
        zenity --info --text="Database created "
    fi

else
    echo "Invalid Name"
    echo
    echo "-------------------------"
    zenity --error --text="Invalid Name"
fi
