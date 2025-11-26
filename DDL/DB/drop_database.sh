#! /usr/bin/bash
 
# source the configuration file
source ./config.sh

# ask the user for the database name
read -p "Enter the name of the database to create: " db_name


# check if the database already exists
if [ -d "$DATA_BASES_DIR/$db_name" ]
then
    
    # drop the database directory
    rm -r "$DATA_BASES_DIR/$db_name"
    echo "Database '$db_name' dropped successfully."

else

    # database does not exist
    echo "Database '$db_name' does not exist."
    
fi
