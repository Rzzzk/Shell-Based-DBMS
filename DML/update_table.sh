#! /usr/bin/bash


shopt -s extglob

#! /usr/bin/bash

shopt -s extglob

echo "Update table script! ${1} database"

# ask the user for the table name
read -p "Enter the name of the table: " table_name


# check if the table already exists
if [ -f "${current_db}/tables/${table_name}" ]
then
    

    echo "Table '$table_name' exists in database."

    # get the column info from the metadata file
    column_names=($(awk 'BEGIN { FS=":"; OFS=" " } { print $1 }' ${current_db}/metadata/${table_name}_meta))
    column_dtypes=($(awk 'BEGIN { FS=":"; OFS=" " } { print $2 }' ${current_db}/metadata/${table_name}_meta))
    column_constraints=($(awk 'BEGIN { FS=":"; OFS=" " } { print $3 }' ${current_db}/metadata/${table_name}_meta))
    column_num=${#column_names[@]}


    # which column to update
    read -p "Enter the name of the column to update: " col_name

    # check if the column exists
    update_column_index=-1
    for (( i=0; i<column_num; i++ ))
    do
        if [[ "${column_names[$i]}" == "$col_name" ]]; then
            update_column_index=$i
            break
        fi
    done

    

    if [[ $update_column_index -eq -1 ]]; then
        echo "Column '$col_name' does not exist in table '$table_name'."
    else
        echo "Updating column '$col_name' in table '$table_name'."

        col_dtype=${column_dtypes[$update_column_index]^^} # convert to uppercase
        col_constraint=${column_constraints[$update_column_index]^^} # convert to uppercase
        column_data=($(awk -F':' -v idx=$((update_column_index+1)) '{print $idx}' ${current_db}/tables/${table_name}))


        error_flag=false 

        echo "Enter new value for column ${col_name} Type: ${col_dtype}, Constraint: ${col_constraint}"
        read -p "> " input_value


        # validate constraints

        # UNIQUE and PK constraint
        if [[ $col_constraint == "UNIQUE" ]] || [[ $col_constraint == "PK" ]]; then
            # check for uniqueness
            for current_value in "${column_data[@]}"
            do
                if [[ $input_value == "$current_value" ]]; then
                    echo "Error: Duplicate value for '$col_constraint' column '$col_name'."
                    error_flag=true
                fi
            done
        fi
        ##########################################################

        # NOT NULL and PK constraint
        if [[ $col_constraint == "NOT NULL" ]] || [[ $col_constraint == "PK" ]]; then
            if [[ -z $input_value ]] || [[ $input_value == "null" ]] || [[ $input_value == "NULL" ]] || [[ $input_value == " " ]]; then
                echo "Error: NULL value not allowed for column '$col_name'."
                error_flag=true
            fi
        fi
        ##########################################################

        # validate input based on data type
        if [[ $col_dtype == "INT" ]]; then

            case $input_value in
            +([0-9]))
                input_value="$input_value"
                ;;
            *)  
                # check for null input
                if [[ -z $input_value ]] || [[ $input_value == "null" ]] || [[ $input_value == "NULL" ]] || [[ $input_value == " " ]]; then
                input_value="null"
                else
                    # invalid input
                    echo "Invalid input. Expected a INT value."
                    error_flag=true
                fi

                ;;
            esac
            
        elif [[ $col_dtype == "STRING" ]]; then
            case $input_value in
            +([0-9]))
                # invalid input
                echo "Invalid input. Expected a STRING value."
                error_flag=true
                ;;
            +([A-z]|[' ']))
                input_value="$input_value"
                ;;
            +([A-z]|[0-9]|[' ']))
                input_value="$input_value"
                ;;
            *)
                # check for null input
                if [[ -z $input_value ]] || [[ $input_value == "null" ]] || [[ $input_value == "NULL" ]] || [[ $input_value == " " ]]; then
                row_values="null"
                else
                    # invalid input
                    echo "Invalid input. Expected a string value."
                    error_flag=true
                fi

                break
                ;;
            esac
            
        fi



        if [[ $error_flag == false ]]; then
            echo "Good value to update"
            echo "${column_data[@]}" 

            # user enter a condition to identify which rows to update
            # ex: update where id=5 or name='Ahmed'or age>30               
        fi


        
    fi

    

else
    # table does not exist
    echo "Table '$table_name' does not exist in database."
fi




