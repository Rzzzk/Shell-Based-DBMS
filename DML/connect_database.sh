#!/usr/bin/bash

# source the configuration file
source ./config.sh

# Using Zenity for displaying the initial message
zenity --info --text="----------------------------------\n-----  Connect to Database  ------\n----------------------------------"

# ask the user for the database name with Zenity entry box
db_name=$(zenity --entry --title="Enter Database Name" --text="Enter the name of the database to connect to:")

# check if the database exists
if [ -d "$DATA_BASES_DIR/$db_name" ]; then
   # Show success message
   zenity --info --text="Connected to database '$db_name' successfully."
   current_db="$DATA_BASES_DIR/$db_name"

   # Database operations menu with Zenity list
   while true; do
      option=$(zenity --list  --title="Database Menu - Connected to '$db_name'"  --column="Option" \
          "List Tables" \
          "Create Table" \
          "Drop Table" \
          "Insert into Table" \
          "Update Table" \
          "Select from Table" \
          "Delete from Table" \
          "Back to Main Menu" \
          "Clear")

      case $option in
         "List Tables") 
            source ./DML/list_tables.sh
            ;;
         "Create Table") 
            source ./DDL/Tables/create_table.sh
            ;;
         "Drop Table") 
            source ./DDL/Tables/drop_table.sh
            ;;
         "Insert into Table") 
            source ./DML/insert_into_table.sh
            ;;
         "Update Table") 
            source ./DML/update_table.sh
            ;;
         "Select from Table") 
            source ./DML/select_from_table.sh "$current_db"
            ;;
         "Delete from Table") 
            source ./DML/delete_from_table.sh "$current_db"
            ;;
         "Back to Main Menu") 
            zenity --info --text="Returning to Main Menu."
            break
            ;;
         "Clear") 
            clear
            ;;
         *)
            zenity --error --text="Invalid option. Please try again."
            ;;
      esac
   done

else
   # Display error message if database doesn't exist
   zenity --error --text="Database '$db_name' does not exist.\nPlease create the database first."
fi

