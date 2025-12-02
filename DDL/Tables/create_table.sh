#! /usr/bin/bash


# get the current database path
echo "-----------------------------------------------"
echo "---  Create table in [${db_name}] database  ---"
echo "-----------------------------------------------"
echo 
# ask the user for the table name
table_name=""
read -p "Enter the name of the table to create: " table_name

## TODO: check if the table name is accepted.
is_name_valid="no"
is_name_valid=$(./Helper_Scripts/name_validation.sh "$table_name")

if [[ "${is_name_valid}" == "yes" ]]; then

    # check if the table already exists
    if [ -f "${current_db}/tables/${table_name}" ]
    then
        echo "Table '$table_name' already exists in database."
    else
        # create the table file
        touch "${current_db}/tables/${table_name}"
        touch "${current_db}/metadata/${table_name}_meta"
        echo "Table '$table_name' created successfully in database."

        # take the number of columns
        while true; do 
            read -p "Enter the number of columns for the table: " num_columns

            if [[ $num_columns -gt 0 ]]; then
            break
            else
            echo "ERROR: Enter a number greater than 0"
            fi
        done

        is_pk_selected="no" # to prevent the duplication of PK
        declare -a col_names # to prevent the duplication of column names

        for (( i=1; i<=num_columns; i++ ))
        do
            #### Column name
            while true; do 
                read -p "Enter the name of column $i: " column_name
                is_name_valid="no"
                is_name_valid=$(./Helper_Scripts/name_validation.sh "$column_name")

                # check if the column name is valid or not
                if [[ "${is_name_valid}" == "yes" ]]; then
                    
                    # check for duplication
                    found="no"
                    for col in "${col_names[@]}"; do
                        if [[ "$col" == "$column_name" ]]; then
                            found="yes"
                            break
                        fi
                    done

                    if [[ "$found" == "yes" ]]; then
                        echo "ERROR: Other column with tha same name, enter other name"
                    else
                        col_names[$i]="${column_name}"
                        break
                    fi

                else
                    echo "ERROR: Enter vaid name"
                fi
            done


            #### Column datatype
            echo "Select data type for column $i:"
            type_options=("INT" "STRING")
            while true; do
                select dtype in "${type_options[@]}"; do
                    case $REPLY in
                        1)  column_type="INT"
                            break 2
                            ;;
                        2)  column_type="STRING"
                            break 2
                            ;;
                        *)  echo "ERROR: Invalid option. Please select 1 or 2." 
                            ;;
                    esac
                done
            done
            
            #### Column constraint
            echo "Select constraint for column $i:"
            constraint_options=("PK" "NOT_NULL" "UNIQUE" "NONE")
            while true; do
                select column_const in "${constraint_options[@]}"; do
                    case $REPLY in
                        1)  
                            if [[ "${is_pk_selected}" == "yes" ]]; then
                                echo "ERROR: primary key column is selected"
                                break
                            else
                                column_const="PK"
                                is_pk_selected="yes"
                                break 2 
                            fi
                            
                            ;;
                        2)  column_const="NOT_NULL"
                            break 2 
                            ;;
                        3)  column_const="UNIQUE"; 
                            break 2 
                            ;;
                        4)  column_const="NONE";
                            break 2 
                            ;;
                        *) echo "ERROR: Invalid option. Please select 1, 2, 3, or 4."
                           break
                           ;;
                    esac
                done
            done
            echo "$column_name:$column_type:$column_const" >> "${current_db}/metadata/${table_name}_meta"
        done
        echo
        echo "-------------------------"
    fi

else
    echo "Invalid Name"
    echo
    echo "-------------------------"
fi


