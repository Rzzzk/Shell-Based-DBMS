#! /usr/bin/bash
#
source ./config.sh
connectedDB=$1

exit_flag=0
select_display_menu(){
    # $1 -> table
    # $2 -> table_data
    # $3 -> meta_data

	    # Show Zenity list dialog
	    option=$(zenity --list \
		--title="Select Option" \
		--column="option" \
		"diplay_all" "specific_columns" "Exit" \
		--height=250 --width=300)

	    case $option in
		"diplay_all")
		output=$(cat "$2")
            zenity --text-info \
                --title="Display All" \
                --width=600 --height=400 \
                --ok-label="Close" \
                --filename=<(echo "$output")
		    #echo "*****************************"
		    #cat "$2"
		    #echo "*****************************"
		    return
		    ;;
		"specific_columns")
		    # get the columns 
		    columns=$(cut -d ":" -f 1 "$3")
		    #echo "$columns" | nl -s " - " -w 1
		    enumerated_col=$(echo "$columns" | nl -s " - " -w 1)
		    num_of_columns=$(wc -l < "$3")
		    echo $enumerated_col
		    
		    declare -a column_to_display
		    while true
		    do  
		    	column_num=$(zenity --entry --title="Columns to Print" --text=" $enumerated_col 
		    	enter the column number u want to display or type (n) to finish :")   
		        #read -p "enter the column number u want to display or type (n) to finish : " column_num
		        
		        if [ "$column_num" = "n" ]; then
		            break 
		        fi
		        
		        # check the validity of the column number entered
		        if [[ ! $column_num =~ ^[1-9]+$ ||  $column_num -gt $num_of_columns ]]; then
		            
			    zenity --info --text="Invalid column number" --title="Error"
		            continue 
		        fi

		        # save them in a visited array 
		        column_to_display[$column_num]=1
		    done
		    
		    # no columns entered return 
		    if [ ${#column_to_display[@]} -eq 0 ]; then
		        return 
		    fi

		    # now display the selected column needed 
		    fields=$(IFS=,; echo "${!column_to_display[*]}")
		    #echo "*****************************"  
		    #echo "*****************************"
		    output=$(cut -d: -f"$fields" "$2")
		    zenity --text-info \
                --title="Display All" \
                --width=600 --height=400 \
                --ok-label="Close" \
                --filename=<(echo "$output")
		    
		    return 
		    ;;
		"Exit")
		    return
		    ;;
		*)
		    zenity --info --text="Invalid Option" --title="Error"
		    ;;
	    esac
}


conditioned_table(){
		#$1 = TableName
		# touch /tmp/tableName copy the table into /tmp/tableName (copy)
		# 1 - ask for column to condition on 
		# 2 - show the availiable column number
		# 3 - enter the column number
		# 4 - filter the /tmp/tableName
		# go-to 1 again  done unitl user type n  
		
		cp $default_path/$connectedDB/tables/$1  /tmp/$1
		
		echo "*******************"
		# print columns 
		while true
			do
				
			columns=$(cut -d ":" -f 1,2 "$default_path/$connectedDB/metadata/$1_meta")
			
			num_of_columns=$(wc -l < "$default_path/$connectedDB/metadata/$1_meta")
			#echo "$columns" | nl -s " - " -w 1
		    	enumerated_col=$(echo "$columns" | nl -s " - " -w 1)
			conditioned_column=$(zenity --entry --title="Codition" --text="$enumerated_col \n 
			enter the column number u want to be conditioned at or (n) to display result :")   
			
			#read -p "enter the column number u want to be conditioned at or (n) to display result : " conditioned_column
			
			
			if [[ ! $conditioned_column  =~ ^[1-9]+$ ||  $conditioned_column -gt $num_of_columns ]]
			then
				zenity --info --text="Invalid column number" --title="Error"
				continue  
			fi  
			
			
			
			if [ $conditioned_column = "n" ] 
			then
				break 
			fi
			  
			# get column type 
			C_type=$(sed -n "${conditioned_column}p" <<< "$columns" | awk -F: '{print $2}')
			echo $C_type
			
			
			
			if [ $C_type = INT ]
			then
				option=$(zenity --list --title="Select Operator for the condition " \
				    --column="Operator" \
				    "==" \
				    ">" \
				    "<")
				#select option in "==" ">" "<"; do
				    case $option in
					"==")
					    # awk on /tmp/$1
					    while true 
					    do
						    value=$(zenity --entry --title="Value" --text="enter value") 
						    
						    # if value is not number break 
						    if [[ $value =~ ^-?[0-9]+$ ]]; then
							echo "You entered a valid integer: $value"
							break
						    else	
						    	
						    		zenity --error  --text="invalid input"
						    fi
					    done
					    #read -p "enter value : " value
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column == value) print }' /tmp/$1  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$1
					    
					    if zenity --question \
						    --title="Add Another Condition?" \
						    --text="Do you want to add another condition?" \
						    --ok-label="Yes" \
						    --cancel-label="No"
						 then
						 	continue
					    else
					   	   break 
					    fi
										    
					    
					    ;;
					">")
					    
					    
					    while true 
					    do
						    value=$(zenity --entry --title="Value" --text="enter value") 
						    
						    # if value is not number break 
						    if [[ $value =~ ^-?[0-9]+$ ]]; then
							echo "You entered a valid integer: $value"
							break
						    else	
						    	
						    		zenity --error  --text="invalid input"
						    fi
					    done
					    #read -p "enter value : " value
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column > value) print }' /tmp/$1  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$1
					    
					    #read -p "do u want to add another condition (y|n): "  conTinue
					    
					    if zenity --question \
						    --title="Add Another Condition?" \
						    --text="Do you want to add another condition?" \
						    --ok-label="Yes" \
						    --cancel-label="No"; then
						    # User clicked Yes
					           continue
					    else
					   	   break 
					    fi
					    
					
					
					    break
					    ;;
					"<")
					
					    
					    while true 
					    do
						    value=$(zenity --entry --title="Value" --text="enter value") 
						    
						    # if value is not number break 
						    if [[ $value =~ ^-?[0-9]+$ ]]; then
							echo "You entered a valid integer: $value"
							break
						    else	
						    	
						    		zenity --error  --text="invalid input"
						    fi
					    done
					    #read -p "enter value : " value
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column < value) print }' /tmp/$1  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$1
					    
					    #read -p "do u want to add another condition (y|n): "  conTinue
					    
							      
					    if zenity --question \
						    --title="Add Another Condition?" \
						    --text="Do you want to add another condition?" \
						    --ok-label="Yes" \
						    --cancel-label="No"; then
						    # User clicked Yes
					          continue
					    else
					   	   break 
					    fi

					    
					    
					    
					    break
					    ;;
					*)
					     zenity --info --text="Invalid Option try again" --title="Error"
					    ;;
				    esac
				    
			   else 
			   # is string 
			   option=$(zenity --list --title="Select Operator for the condition " \
				    --column="Operator" \
				    "==" )
			   #select option in "==" ; do
				    case $option in
					"==")
					    # awk on /tmp/$1
					    
					    value=$(zenity --entry --title="Value" --text="enter value") 
					    #read -p "enter value : " value
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column == value) print }' /tmp/$1  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$1
					    
					    #read -p "do u want to add another condition (y|n): "  conTinue
					    
					    if zenity --question \
						    --title="Add Another Condition?" \
						    --text="Do you want to add another condition?" \
						    --ok-label="Yes" \
						    --cancel-label="No"; then
						    # User clicked Yes
					           continue
					    else
					   	   break 
					    fi
					    
					    
					    
					    ;;
					"*")
					     zenity --info --text="Invalid Option try again" --title="Error"
						;;
			   	      esac
			   
			   
			fi
				
		 done
		 
		 select_display_menu $1 /tmp/$1 $default_path/$connectedDB/metadata/$1_meta
		 
		 
		 
		
		




}

select_table() {
	    while true; do
		# Ask for Table Name using zenity entry box
		TableName=$(zenity --entry --title="Enter Table Name" --text="Enter the table name:")

		# Check if the table exists
		if [ -f "$default_path/$connectedDB/tables/$TableName" ]; then
		    break  # Table exists, break the loop
		else
		    # Table doesn't exist, show error message
		    zenity --error --text="Table '$TableName' doesn't exist. Please try again."
		fi
	    done

	    # Show the options menu with zenity --list
	    option=$(zenity --list --title="Select Operation for Table '$TableName'" \
		            --column="Option" \
		            "Conditioned" \
		            "NotCondition" \
		            "Exit")

	    case $option in
		"Conditioned")
		    # Call the conditioned table function (pass TableName as argument)
		    conditioned_table "$TableName"
		    return
		    ;;
		"NotCondition")
		    # Call the select_display_menu function (pass TableName and file paths)
		    select_display_menu "$TableName" "$default_path/$connectedDB/tables/$TableName" "$default_path/$connectedDB/metadata/${TableName}_meta"
		    return
		    ;;
		"Exit")
		    # Exit the function if 'Exit' is selected
		    return
		    ;;
		*)
		    # Handle invalid option
		    zenity --error --text="Invalid option. Please try again."
		    ;;
	    esac
}


select_table 

