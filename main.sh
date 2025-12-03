#!/bin/bash

# Start the DBMS
zenity --info --text="Welcome to our DBMS!" --title="DBMS" 

# Start the main loop
while true; do
    # Display options to the user using Zenity's --list option
    optuins=("Create Database" "List Databases" "Connect to Database" "Drop Database" "Clear" "Exit")
    
    # Create a selection dialog with Zenity
    choice=$(zenity --list --title="Main Menu" --column="Option" "${optuins[@]}")

    # Check the user's choice and act accordingly
    case $choice in
        "Create Database")
            # Run the create_database.sh script
            ./DDL/DB/create_database.sh
            ;;
        "List Databases")
            # Run the list_databases.sh script
            ./DDL/DB/list_databases.sh
            ;;
        "Connect to Database")
            # Run the connect_database.sh script
            ./DML/connect_database.sh
            ;;
        "Drop Database")
            # Run the drop_database.sh script
            ./DDL/DB/drop_database.sh
            ;;
        "Clear")
            # Clear the terminal screen
            clear
            ;;
        "Exit")
            # Exit the DBMS
            zenity --info --text="Exiting the DBMS. Goodbye!" --title="Goodbye"
            break # Exit the main loop
            ;;
        *)
            # Handle invalid option (this should never happen)
            zenity --error --text="Invalid option. Please try again." --title="Error"
            ;;
    esac
done

# End the DBMS

