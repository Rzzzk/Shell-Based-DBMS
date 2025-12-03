#! /usr/bin/bash

shopt -s extglob

echo "----------------------------------"
echo "-----  Insert into table    ------"
echo "----------------------------------"
echo


# ask the user for the table name
read -p "Enter the name of the table: " table_name
table_name="${table_name//[[:space:]]/}"


# check if the table already exists
if [ -f "${current_db}/tables/${table_name}" ]
then
    

    echo "Table '$table_name' exists in database."

    # get the column info from the metadata file
    column_names=($(awk 'BEGIN { FS=":"; OFS=" " } { print $1 }' ${current_db}/metadata/${table_name}_meta))
    column_dtypes=($(awk 'BEGIN { FS=":"; OFS=" " } { print $2 }' ${current_db}/metadata/${table_name}_meta))
    column_constraints=($(awk 'BEGIN { FS=":"; OFS=" " } { print $3 }' ${current_db}/metadata/${table_name}_meta))
    column_num=${#column_names[@]}


    # loop through each column and get the value from the user for each column
    row_values=""
    error_flag=false

    for (( i=0; i<column_num; i++ ))
    do

        # get column info
        col_name=${column_names[$i]}
        col_dtype=${column_dtypes[$i]^^} # convert to uppercase
        col_constraint=${column_constraints[$i]^^} # convert to uppercase

        # get existing data in the column for constraint checks
        column_data=($(awk -v col=$((i+1)) 'BEGIN { FS=":"; OFS="," } { print $col }' ${current_db}/tables/${table_name}))

        # prompt the user for input
        echo "Enter value for column ${col_name} Type: ${col_dtype}, Constraint: ${col_constraint}"
        
        
        # read user input
        input_value=""
        read -p "> " input_value
        input_value="${input_value//[[:space:]]/}"

        
        echo

        # validate constraints

        # UNIQUE and PK constraint
        if [[ $col_constraint == "UNIQUE" ]] || [[ $col_constraint == "PK" ]]; then
            # check for uniqueness
            for current_value in "${column_data[@]}"
            do
                if [[ $input_value == "$current_value" ]]; then
                    echo "Error: Duplicate value for '$col_constraint' column '$col_name'."
                    error_flag=true
                    echo
                    echo "----------------------------------------"
                    break 2 # exit both loops
                fi
            done
        fi

        # NOT_NULL and PK constraint
        if [[ $col_constraint == "NOT_NULL" ]] || [[ $col_constraint == "PK" ]]; then
            if [[ -z $input_value ]] || [[ $input_value == "null" ]] || [[ $input_value == "NULL" ]] || [[ $input_value == " " ]]; then
                echo "Error: NULL value not allowed for column '$col_name'."
                error_flag=true
                echo
                echo "----------------------------------------"
                break 2 # exit both loops
            fi
        fi


        # validate input based on data type
        if [[ $col_dtype == "INT" ]]; then

            case $input_value in
            +([0-9]))
                row_values+=":${input_value}"
                ;;
            *)  
                # check for null input
                if [[ -z $input_value ]] || [[ $input_value == "null" ]] || [[ $input_value == "NULL" ]] || [[ $input_value == " " ]]; then
                row_values+=":null"
                else
                    # invalid input
                    echo "Invalid input. Expected a string value."
                    error_flag=true
                fi

                break
                ;;
            esac
            
        elif [[ $col_dtype == "STRING" ]]; then
            case $input_value in
            +([0-9]))
                # invalid input
                echo "Invalid input. Expected a string value."
                error_flag=true
                break
                ;;
            +([A-z]|[' ']))
                row_values+=":${input_value}"
                ;;
            +([A-z]|[0-9]|[' ']))
                row_values+=":${input_value}"
                ;;
            *)
                # check for null input
                if [[ -z $input_value ]] || [[ $input_value == "null" ]] || [[ $input_value == "NULL" ]] || [[ $input_value == " " ]]; then
                row_values+=":null"
                else
                    # invalid input
                    echo "Invalid input. Expected a string value."
                    error_flag=true
                fi

                break
                ;;
            esac
            
        fi
        
    done

    # check if there was any error during input
    if [[ $error_flag == false ]]; then
        # print the row values
        echo "Row values: ${row_values:1}"

        # insert the row into the table
        echo "${row_values:1}" >> "${current_db}/tables/${table_name}"
        echo "Row inserted successfully into table '$table_name'."
        echo
        echo "----------------------------------------"
    fi


else
    # table does not exist
    echo "Table '$table_name' does not exist in database."
    echo
    echo "----------------------------------------"
fi



