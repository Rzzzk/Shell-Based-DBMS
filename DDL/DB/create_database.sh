#! /usr/bin/bash

# source the configuration file
source ./config.sh


# ask the user for the database name
read -p "Enter the name of the database to create: " db_name

# check if the database name is accepted.

# check if the database already exists
if [ -d "$DATA_BASES_DIR/$db_name" ]
then
    echo "Database '$db_name' already exists."
    echo "Please choose a different name."
else
    # create the database directory
    mkdir -p "$DATA_BASES_DIR/$db_name/tables"
    mkdir -p "$DATA_BASES_DIR/$db_name/metadata"

    echo "Database '$db_name' created successfully."
fi
