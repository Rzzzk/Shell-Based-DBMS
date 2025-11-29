#! /usr/bin/bash

#
source ./config.sh
connectedDB=$1


exit_flag=0
delete_table(){

	#cat /tmp/$1
	echo "*******************"	
	while true 
	do 
		read -p "Enter Table Name" TableName
		
		if [ -f $default_path/$connectedDB/tables/$TableName ]
		then
			break 
		else
			echo "table doesn't exist "
		fi
	done 	
	
	cp $default_path/$connectedDB/tables/$TableName  /tmp/$TableName
	
	while true
			do
				
			columns=$(cut -d ":" -f 1,2 "$default_path/$connectedDB/metadata/${TableName}_meta")
			num_of_columns=$(wc -l < "$default_path/$connectedDB/metadata/${TableName}_meta")
			echo "$columns" | nl -s " - " -w 1
			read -p "enter the column number u want to be conditioned at or (n) to display result : " conditioned_column
			
			
			if [ $conditioned_column -gt  $num_of_columns  ] 
			then
				echo "invalid number"
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
				select option in "==" ">" "<"; do
				    case $option in
					"==")
					    
					    read -p "enter value : " value
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column != value) print }' /tmp/$TableName  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$TableName
					    
					    read -p "do u want to add another condition (y|n)"  conTinue
					    
							      
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
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column <= value) print }' /tmp/$TableName  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$TableName
					    
					    read -p "do u want to add another condition (y|n)"  conTinue
					    
							      
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
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column >= value) print }' /tmp/$TableName  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$TableName
					    
					    read -p "do u want to add another condition (y|n)"  conTinue
					    
							      
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
					    read -p "enter value : " value
					    # awk comparsion
					    awk -F: -v value="$value" -v column="$conditioned_column" '{ if ($column != value) print }' /tmp/$TableName  >  /tmp/con_temp
					    mv /tmp/con_temp /tmp/$TableName
					    
					    read -p "do u want to add another condition (y|n)"  conTinue
					    
							      
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
		 echo  /tmp/$TableName
		 echo  $default_path/$connectedDB/tables/$TableName
		 mv /tmp/$TableName $default_path/$connectedDB/tables/$TableName
		 
		 
}
		
delete_table  

