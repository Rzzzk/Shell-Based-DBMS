#! /usr/bin/bash

# (Removed duplicate shebang and shopt from original snippet)
shopt -s extglob

# REPLACED: Header echos with a Zenity notification or just title usage in dialogs.
# echo "----------------------------------"
# echo "------   Update table       ------"
# echo "----------------------------------"

# ask the user for the table name
# REPLACED: read -p "Enter the name of the table: " table_name
table_name=$(zenity --entry --title="Update Table" --text="Enter the name of the table to update:")

table_name="${table_name//[[:space:]]/}"

# check if the table already exists
if [ -f "${current_db}/tables/${table_name}" ]
then

    # REPLACED: echo "Table '$table_name' exists in database." 
    # (Silent success, moving to next step)

    # get the column info from the metadata file
    column_names=($(awk 'BEGIN { FS=":"; OFS=" " } { print $1 }' ${current_db}/metadata/${table_name}_meta))
    column_dtypes=($(awk 'BEGIN { FS=":"; OFS=" " } { print $2 }' ${current_db}/metadata/${table_name}_meta))
    column_constraints=($(awk 'BEGIN { FS=":"; OFS=" " } { print $3 }' ${current_db}/metadata/${table_name}_meta))
    column_num=${#column_names[@]}


    # which column to update
    # REPLACED: echo "Columns ${column_names[@]}" and read -p
    # STRATEGY: Use a List dialog so user can't make a typo
    col_name=$(zenity --list --title="Select Column" --text="Select the column to update:" --column="Column Name" "${column_names[@]}")
    col_name="${col_name//[[:space:]]/}"

    # check if the column exists
    update_column_index=-1
    for (( i=0; i<column_num; i++ ))
    do
        if [[ "${column_names[$i]^^}" == "${col_name^^}" ]]; then
            update_column_index=$i
            break
        fi
    done

    

    if [[ $update_column_index -eq -1 ]]; then
        # REPLACED: echo "Column '$col_name' does not exist..."
        zenity --error --text="Column '$col_name' does not exist in table '$table_name'."
    else
        # REPLACED: echo "Updating column..." (Silent processing)

        col_dtype=${column_dtypes[$update_column_index]^^} # convert to uppercase
        col_constraint=${column_constraints[$update_column_index]^^} # convert to uppercase
        column_data=($(awk -F':' -v idx=$((update_column_index+1)) '{print $idx}' ${current_db}/tables/${table_name}))


        error_flag=false 

        # REPLACED: echo "Enter new value..." and read -p
        input_value=$(zenity --entry --title="Update Value" --text="Enter new value for column ${col_name} \nType: ${col_dtype}\nConstraint: ${col_constraint}")
        
        input_value="${input_value//[[:space:]]/}"
        
        # validate constraints

        # UNIQUE and PK constraint
        if [[ $col_constraint == "UNIQUE" ]] || [[ $col_constraint == "PK" ]]; then
            # check for uniqueness
            for current_value in "${column_data[@]}"
            do
                if [[ $input_value == "$current_value" ]]; then
                    # REPLACED: echo Error
                    zenity --error --text="Error: Duplicate value for '$col_constraint' column '$col_name'."
                    error_flag=true
                fi
            done
        fi
        ##########################################################

        # NOT_NULL and PK constraint
        if [[ $col_constraint == "NOT_NULL" ]] || [[ $col_constraint == "PK" ]]; then
            if [[ -z $input_value ]] || [[ $input_value == "null" ]] || [[ $input_value == "NULL" ]] || [[ -z "${input_value//[[:space:]]/}" ]]; then
                # REPLACED: echo Error
                zenity --error --text="Error: NULL value not allowed for column '$col_name'."
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
            +([' ']))
                row_values+=":null"
                ;;
            *)  
                # check for null input
                if [[ -z $input_value ]] || [[ $input_value == "null" ]] || [[ $input_value == "NULL" ]] || [[ -z "${input_value//[[:space:]]/}" ]]; then
                input_value="null"
                else
                    # invalid input
                    # REPLACED: echo Invalid input
                    zenity --error --text="Invalid input. Expected a INT value."
                    error_flag=true
                fi

                ;;
            esac
            
        elif [[ $col_dtype == "STRING" ]]; then
            case $input_value in
            +([0-9]))
                # invalid input
                # REPLACED: echo Invalid input
                zenity --error --text="Invalid input. Expected a STRING value."
                error_flag=true
                ;;
            +([' ']))
                row_values+=":null"
                ;;
            +([A-z]|[' ']))
                input_value="$input_value"
                ;;
            +([A-z]|[0-9]|[' ']))
                input_value="$input_value"
                ;;
            *)
                # check for null input
                if [[ -z $input_value ]] || [[ $input_value == "null" ]] || [[ $input_value == "NULL" ]] || [[ -z "${input_value//[[:space:]]/}" ]]; then
                    input_value="null"
                else
                    # invalid input
                    # REPLACED: echo Invalid input
                    zenity --error --text="Invalid input. Expected a string value."
                    error_flag=true
                    break
                fi
                ;;
            esac
            
        fi



        if [[ $error_flag == false ]]; then
            #echo "Good value to update"
            #echo "${column_data[@]}" 

            # user enter a condition to identify which rows to update
            # ex: update where id=5 or name='Ahmed'or age>30
            
            # REPLACED: echo available conditions and read -p
            condition=$(zenity --entry --title="Where Condition" --text="Enter condition to identify rows (e.g., col>5)\nAvailable ops: [=, >, <]")
            
            # parse the condition
            condition_column=$(echo $condition | awk -F'[=<>]' '{print $1}')
            condition_operator=$(echo $condition | grep -o '[=<>]' )
            condition_value=$(echo $condition | awk -F'[=<>]' '{print $2}')
            # handle spaces
            condition_column="${condition_column//[[:space:]]/}"
            condition_operator="${condition_operator//[[:space:]]/}"
            condition_value="${condition_value//[[:space:]]/}"
            

            # find the index of the condition column
            condition_column_index=-1
            for (( i=0; i<column_num; i++ ))
            do
                if [[ "${column_names[$i]^^}" == "${condition_column^^}" ]]; then
                    condition_column_index=$i
                    break
                fi
            done

            # check if the condition column exists
            if [[ $condition_column_index -eq -1 ]]; then
                # REPLACED: echo error
                zenity --error --text="Condition column '$condition_column' does not exist in table '$table_name'."
            else

                # get the data of the condition column
                condition_column_data=($(awk -F':' -v idx=$((condition_column_index+1)) '{print $idx}' ${current_db}/tables/${table_name}))
                #echo "Condition column data: ${condition_column_data[@]}"

                # print confirmation
                #echo "Condition column '$condition_column' found in table '$table_name'."

                # iterate through the condition column data to find matching rows
                for (( i=0; i<${#condition_column_data[@]}; i++ ))
                do
                    match=false
                    case $condition_operator in
                    "=")
                        if [[ "${condition_column_data[$i]}" == "$condition_value" ]]; then
                            match=true
                        fi
                        ;;
                    "<")
                        if [[ "${condition_column_data[$i]}" -lt "$condition_value" ]]; then
                            match=true
                        fi
                        ;;
                    ">")
                        if [[ "${condition_column_data[$i]}" -gt "$condition_value" ]]; then
                            match=true
                        fi
                        ;;
                    esac

                    # if row matches condition, update it
                    if [[ $match == true ]]; then
                        #echo "Updating row $((i+1))"

                        # read the entire row and update the specific column
                        row_data=($(awk -F':' -v row=$((i+1)) '{if(NR==row) print $0}' ${current_db}/tables/${table_name}))

                        
                        # Ex: old_dat = "1:Ahmed:25" >> array ( 1 Ahmed  25 )
                        # access the index needed and update it
 
                        # row_data isseperated by : use sed to update the specific column 
                        # cann't use array index directly
                        # row_data[$update_column_index]="$input_value" is not working
                        # row_data is not array but a string
                        # need to split it into array first
                        IFS=':' read -r -a row_array <<< "${row_data[*]}"
                        row_array[$update_column_index]="$input_value"



                        # return the updated row as a string
                        updated_row=$(IFS=':'; echo "${row_array[*]}")
                        #echo "Updated row data: $updated_row"

                        # so the row number i+1 needs to be updated in the table file
                        # use sed to update the specific line in the file
                        sed -i "$((i+1))s/.*/$updated_row/" ${current_db}/tables/${table_name}
                        
                        zenity --info --title="Success" --text="Row $((i+1)) updated successfully."
                        
                    fi
                done

                # REPLACED: echo success
                zenity --info --title="Success" --text="Update completed successfully."

            fi
        else 
            # Place holder for else block if needed
            :
        fi
        
    fi

else
    # table does not exist
    # REPLACED: echo error
    zenity --error --text="Table '$table_name' does not exist in database."
fi