#! /usr/bin/bash
 

# source the configuration file
source ./config.sh

echo "----------------------------------"
echo "-----  Connect to Database  ------"
echo "----------------------------------"
echo


# ask the user for the database name
db_name=""
read -p "Enter the name of the database to connect to: " db_name

# check if the database exists
if [ -d "$DATA_BASES_DIR/$db_name" ]
then

   # connect to the database
   echo "Connected to database '$db_name' successfully."
   current_db="$DATA_BASES_DIR/$db_name"
   echo
   # database operations menu
   option=(
      "List Tables"
      "Create Table"
      "Drop Table"
      "Insert into Table"
      "Update Table"
      "Select from Table"
      "Delete from Table"
      "Back to Main Menu"
      "Clear"
   )

   # start the database operations loop
   while true; do
      echo "Database Menu - Connected to '$db_name':"
      select opt in "${option[@]}"; do
         case $REPLY in
               1) source ./DML/list_tables.sh
               break
                  ;;
               2) source ./DDL/Tables/create_table.sh
               break
                  ;;
               3) source ./DDL/Tables/drop_table.sh "$current_db"
               break
                  ;;
               4) source ./DML/insert_into_table.sh "$current_db"
               break
                  ;;
               5) source ./DML/update_table.sh "$current_db"
                  ;;
               6) source ./DML/select_from_table.sh "$current_db"
                  ;;
               7) source ./DML/delete_from_table.sh "$current_db"
                  ;;
               8) echo "Returning to Main Menu."
                  break 2
                  ;;
               9) clear 
                  break
                  ;;
               *) echo "Invalid option. Please try again."
                  ;;
         esac
      done
   done

else
    echo "Database '$db_name' does not exist."
    echo "Please create the database first."
    echo
    echo "-------------------------"
fi
