#! /usr/bin/bash


# get the current database path
current_db=${1}
echo "create table in << ${current_db} >> database"

# ask the user for the table name
read -p "Enter the name of the table to create: " table_name


# check if the table already exists
if [ -f "${current_db}/tables/${table_name}" ]
then
    echo "Table '$table_name' already exists in database."
else
    # create the table file
    touch "${current_db}/tables/${table_name}"
    touch "${current_db}/metadata/${table_name}_meta"
    echo "Table '$table_name' created successfully in database."


    # take the colmns from the user
    read -p "Enter the number of columns for the table: " num_columns
    for (( i=1; i<=num_columns; i++ ))
    do
        read -p "Enter the name of column $i: " column_name
        read -p "Enter the data type of column $i (e.g., INT, STRING): " column_type
        read -p "Is this column a primary key? (y/n): " is_primary_key

        # write the column metadata to the metadata file
        if [ "$is_primary_key" == "y" ] || [ "$is_primary_key" == "Y" ]; then
            echo "$column_name:$column_type:PK" >> "${current_db}/metadata/${table_name}_meta"
        else
            echo "$column_name:$column_type" >> "${current_db}/metadata/${table_name}_meta"
        fi
    done
fi
