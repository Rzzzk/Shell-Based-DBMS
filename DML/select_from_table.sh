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
		        
		        
		    return
		    ;;
		    
		    
		    
		 "specific_columns")

			columns=$(cut -d ":" -f 1 "$3")

			# build zenity checklist data
			checklist_data=()
			while IFS= read -r col; do
			    checklist_data+=(FALSE "$col")
			done <<< "$columns"

			# show checklist menu
			selected_columns=$(zenity --list \
			    --checklist \
			    --title="Select Columns to Display" \
			    --text="Choose the columns you want to display:" \
			    --column="Select" --column="Column Name" \
			    "${checklist_data[@]}" \
			    --width=400 --height=300 \
			    --separator=":")

			# if user closed or selected nothing
			if [ -z "$selected_columns" ]; then
			    zenity --info --text="No columns selected"
			    return
			fi

			# convert selected column NAMES 
			fields=""
			while IFS=":" read -ra selected; do
			    for col in "${selected[@]}"; do
				num=$(grep -n -w "$col" <<< "$columns" | cut -d: -f1)  # 3:column3
				fields+="$num,"
			    done
			done <<< "$selected_columns"

			# remove trailing comma
			fields=${fields%,}

			# extract selected columns from data file ($2)
			output=$(cut -d: -f"$fields" "$2")

			# display result
			zenity --text-info \
			    --title="Selected Columns" \
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
		# touch /tmp/tableName copy the table into /tmp/tableName (copy)   (older version select and )
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
				# get the INT value 
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
					    
					    
				option=$(zenity --list --title="Select Operator for the condition " \
				    --column="Operator" \
				    "==" \
				    ">" \
				    "<")
				#select option in "==" ">" "<"; do
				    case $option in
					"==")
					    # awk on /tmp/$1
					    
					    #read -p "enter value : " value
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column == value) print }' /tmp/$1  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$1
					    
					    break
										    
					    
					    ;;
					">")
					
					    #read -p "enter value : " value
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column > value) print }' /tmp/$1  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$1
					    
					    #read -p "do u want to add another condition (y|n): "  conTinue
					    
					    break
					    
					
					
					    break
					    ;;
					"<")
					    #read -p "enter value : " value
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column < value) print }' /tmp/$1  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$1
					    
					    break
					    
					    
					    
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
					    
					    break 
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

