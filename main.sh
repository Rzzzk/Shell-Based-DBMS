#! /usr/bin/bash

# start the DBMS
echo "Welcome to our DBMS!"

# start the main loop
while true; do
    
    # show the main menu using
    optuins=("Create Database" "List Databases" "Connect to Database" "Drop Database" "Exit")
    echo "Main Menu:"


    select opt in "${optuins[@]}"; do
        case $REPLY in
            1) source ./DDL/DB/create_database.sh
               ;;
            2) source ./DDL/DB/list_databases.sh
               ;;
            3) source ./DML/connect_database.sh
               ;;
            4) source ./DDL/DB/drop_database.sh
               ;;
            5) echo "Exiting the DBMS. Goodbye!"
               break 2
               ;;
            *) echo "Invalid option. Please try again."
               ;;
        esac
    done


done
# end the DBMS
