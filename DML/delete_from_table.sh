#! /usr/bin/bash

#
source ./config.sh
connectedDB=$1


exit_flag=0
delete_table(){

	#cat /tmp/$1
	echo "*******************"	
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
	
	cp $default_path/$connectedDB/tables/$TableName  /tmp/$TableName
	
	while true
			do
			# get the column names numerated 	
			columns=$(cut -d ":" -f 1,2 "$default_path/$connectedDB/metadata/${TableName}_meta")
			num_of_columns=$(wc -l < "$default_path/$connectedDB/metadata/${TableName}_meta")
			enumerated_col=$(echo "$columns" | nl -s " - " -w 1)
			
			conditioned_column=$(zenity --entry --title="Codition" --text="$enumerated_col \n 
			enter the column number u want to be conditioned at or (n) to display result :")   
			
			if [[ ! $conditioned_column  =~ ^[1-9]+$ ||  $conditioned_column -gt $num_of_columns ]]
			then
		   		 zenity --error --text="Invalid Column number"
				continue  
			fi  
			
			
			
			if [ $conditioned_column = "n" ] 
			then
				break 
			fi  
			
			C_type=$(sed -n "${conditioned_column}p" <<< "$columns" | awk -F: '{print $2}')
			echo $C_type
			
			if [ $C_type = INT ]
			then
				#select option in "==" ">" "<"; do
				option=$(zenity --list --title="Select Operator for the condition " \
				    --column="Operator" \
				    "==" \
				    ">" \
				    "<")
				    
				    case $option in
					"==")
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
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column != value) print }' /tmp/$TableName  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$TableName
					    
					    
						
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
					    done   # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column <= value) print }' /tmp/$TableName  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$TableName
					    
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
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column >= value) print }' /tmp/$TableName  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$TableName
					    
					    
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
						
					    
					    
					    
					    break
					    ;;
					*)
						zenity --error --text="Invalid Choice "
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
					    
					    value=$(zenity --entry --title="Value" --text="enter value") 
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column != value) print }' /tmp/$TableName  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$TableName
					    
					    
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
					"*")
					
						zenity --error --text="Invalid Choice "
						;;
			   	      esac
			   
			fi
				
		 done
		 echo "Rows Deleted"
		 mv /tmp/$TableName $default_path/$connectedDB/tables/$TableName
		 
		 
}
		
delete_table  

