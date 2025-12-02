#! /usr/bin/bash

# start the DBMS
echo "Welcome to our DBMS!"

# start the main loop
while true; do
    
   # show the main menu using
   optuins=("Create Database" "List Databases" "Connect to Database" "Drop Database" "Clear" "Exit")
   echo "Main Menu:"

   # display options to the user 
   # prompt the user to select an option
   # use a select loop to handle user input
   select opt in "${optuins[@]}"; do
      case $REPLY in
         1) source ./DDL/DB/create_database.sh
            break # exit the select loop to return to the main loop and show the menu again
            ;;
         2) source ./DDL/DB/list_databases.sh
            break # exit the select loop to return to the main loop and show the menu again
            ;;
         3) source ./DML/connect_database.sh
            break # exit the select loop to return to the main loop and show the menu again
            ;;
         4) source ./DDL/DB/drop_database.sh
            break # exit the select loop to return to the main loop and show the menu again
            ;;
         5) clear # clear the terminal screen
            break # exit the select loop to return to the main loop and show the menu again
            ;;
         6) echo "Exiting the DBMS. Goodbye!"
            break 2 # exit both loops (the select and the while)
            ;;
         *) echo "Invalid option. Please try again."
            break # exit the select loop to return to the main loop and show the menu again
            ;;
      esac
   done

done
# end the DBMS
