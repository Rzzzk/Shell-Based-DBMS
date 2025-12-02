#! /usr/bin/bash
#
source ./config.sh
connectedDB=$1

exit_flag=0

select_display_menu(){
		 # $1 ->table
		 # $2 -> table_data
		 # $3 -> meta_data


	select option in "diplay_all" "specific_columns" ; do
	    case $option in
		"diplay_all")
			echo "*****************************"
			cat  $2
			echo "*****************************"
			return
		    ;;
		"specific_columns")
			# get the columns 
			columns=$(cut -d ":" -f 1 "$3")
			echo "$columns" | nl -s " - " -w 1
			num_of_columns=$(wc -l < "$3")
			
			
			declare -a column_to_display
			while true
			do 	
			
				read -p "enter the column number u want to display or type (n) to finish : " column_num
				
				
				if [ $column_num = "n" ]
				then
					break 
				fi
				
				
				# check the validiaty of the column number entered
				if [[ ! $column_num  =~ ^[1-9]+$ ||  $column_num -gt $num_of_columns ]]
				then
					
					echo "Invalid Column Number"
					
					continue 
				fi
				
				
				
				
				# save them in a visited array 
				column_to_display[$column_num]=1
			
			done
			
			# no columns entered return 
			if [ ${#column_to_display[@]} -eq 0 ]
			then
				return 
			fi
			# now display the selected column needed 
			fields=$(IFS=,; echo "${!column_to_display[*]}")
			echo "*****************************"
			cut -d: -f"$fields" $2
			echo "*****************************"
			
			
			return 
			
		    ;;
		"Exit")
			return
		    ;;
		*)
		    echo "Invalid option. Try again."
		    ;;
	    esac
	done



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
			echo "$columns" | nl -s " - " -w 1
			read -p "enter the column number u want to be conditioned at or (n) to display result : " conditioned_column
			
			
			if [[ ! $conditioned_column  =~ ^[1-9]+$ ||  $conditioned_column -gt $num_of_columns ]]
			then
				echo "invalid number"
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
				select option in "==" ">" "<"; do
				    case $option in
					"==")
					    # awk on /tmp/$1
					    
					    read -p "enter value : " value
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column == value) print }' /tmp/$1  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$1
					    
					    read -p "do u want to add another condition (y|n): "  conTinue
					    
							      
					    if [ $conTinue = "y" ] 
					    then
					    		break 
					    
					    else 
					    		break 2 
					    
					    fi  
					    
					    
					    
					    ;;
					">")
					    
					
					    read -p "enter value : " value
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column > value) print }' /tmp/$1  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$1
					    
					    read -p "do u want to add another condition (y|n): "  conTinue
					    
							      
					    if [ $conTinue = "y" ] 
					    then
					    		break 
					    
					    else 
					    		break 2 
					    
					    fi  
					    
					    
					
					
					    break
					    ;;
					"<")
					
					    read -p "enter value : " value
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column < value) print }' /tmp/$1  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$1
					    
					    read -p "do u want to add another condition (y|n): "  conTinue
					    
							      
					    if [ $conTinue = "y" ] 
					    then
					    		break 
					    
					    else 
					    		break 2 
					    
					    fi  
					    
					    
					    
					    break
					    ;;
					*)
					    echo "Invalid option. Try again."
					    ;;
				    esac
				done
			   else 
			   # is string 
			   select option in "==" ; do
				    case $option in
					"==")
					    # awk on /tmp/$1
					    
					    read -p "enter value : " value
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column == value) print }' /tmp/$1  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$1
					    
					    read -p "do u want to add another condition (y|n): "  conTinue
					    
							      
					    if [ $conTinue = "y" ] 
					    then
					    		break 
					    
					    else 
					    		break 2 
					    
					    fi  
					    
					    
					    
					    ;;
					"*")
						"invalid"
						;;
			   	      esac
			   done
			   
			   
			fi
				
		 done
		 
		 select_display_menu $1 /tmp/$1 $default_path/$connectedDB/metadata/$1_meta
		 
		 
		 
		
		




}

select_table(){	
	while true 
	do 
		read -p "Enter Table Name: " TableName
		
		if [ -f $default_path/$connectedDB/tables/$TableName ]
		then
			break 
		else
			echo "table doesn't exist "
		fi
	done 	
		select option in "Conditioned" "NotCondition" "Exit"; do
		    case $option in
			"Conditioned")
			
			    conditioned_table $TableName
			    
			    return 
			    ;;
			"NotCondition")
			     select_display_menu $TableName $default_path/$connectedDB/tables/$TableName  $default_path/$connectedDB/metadata/${TableName}_meta
			     return
			    ;;
			"Exit")
			    
			    return
			    ;;
			*)
			    echo "Invalid option. Try again."
			    ;;
		    esac
		done
}

select_table 

