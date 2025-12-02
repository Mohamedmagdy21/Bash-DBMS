#! /usr/bin/bash

PS3="DMS>>"


while true
 do
 clear
 echo "Enter table you wish to insert in: "
     read table
    

       if [ ! -f "./databases/$DBName/$table" ]; then
           echo "No table was found."
           break;
       elif [[ "$table" =~ [^a-zA-Z0-9_] ]]; then
            echo "Error: Table name '$table' contains special characters or spaces. Only      letters, numbers, and underscores are allowed."
    break    
       else
           row=""
           sep=":"
           colsNum=$(grep -v '^$' "./databases/$DBName/$table.meta" | wc -l)
           echo "Number of Columns: $colsNum"
           for i in $(seq 1 $colsNum)
             do
             lineContent=$(sed -n "${i}p" < ./databases/$DBName/$table.meta )
             colName=$(echo "$lineContent" | cut -d':' -f1)
             colType=$(echo "$lineContent" | cut -d':' -f2)
             colKey=$(echo "$lineContent" | cut -d':' -f3)
             while true
              do
               isPk=false
               echo "enter the value for $colName of type $colType "
               if [ "$colKey" == "pk" ]; then
                echo "which is a primary key"
                isPk="true"
               fi
               read input
               if [ -z "$input" ]; then
                 echo "Error: Primary Key cannot be empty."
                 continue
               fi  
               if [ "$colType" == "int" ]; then
                 
                 if ! [[ "$input" =~ ^[0-9]+$ ]]; then
                   echo "invalid input, input should only be an int"
                   continue 
                   fi
                fi   
                   
               if [ "$colType" == "str" ]; then
               
                 if ! [[ "$input" =~ ^[A-Za-z][A-Za-z0-9]*$ ]]; then
                    echo "Invalid input: must begin with a letter and contain only letters or digits"
                     continue
                 fi

               fi   
               
               if [ "$isPk" == true ]; then
                  existValues=$(cut -d'|' -f"$i" "./databases/$DBName/$table")
                  
                 for value in $existValues
                   do
                   if [ "$value" == "$input" ]; then
                     echo "Primary key '$input' already exists! "
                     continue 2
                   fi
                  done
                fi     
                  
                if [ -z "$row" ]; then
                  row="$input"
                else
                  row="$row|$input"
                fi

                break  
               done  
             done        
                   
                    
               
           
           
           firstEmpty=$(grep -n '^$' ./databases/$DBName/$table | head -1 | cut -d'|' -f1 )
           if [ -n "$firstEmpty" ]; then
            # Replace that empty line with the full row
              sed -i "${firstEmpty}s/^$/$row/" "./databases/$DBName/$table"
           else
            # If no empty lines → append at the end
               echo "$row" >> "./databases/$DBName/$table"

            fi

                
         fi
       
        # echo " Do you wish to continue (Y/N)?"
        # read inp
        # if [ "$inp" == "Y" ]; then
        #   continue
        # else
        #    break
        # fi  
        
        echo
        echo "---------------------------------------------"
        echo " Exit this selection?"
        echo "---------------------------------------------"

 
        select var in "yes" "no"                 # exit and return back to the previous menu
		do
	         case $var in
			yes ) 
				echo "Exiting..."
				unset output
				break 2;;
			no )
				echo "Continuing..."
				break;;
				
			* ) echo "Wrong Choice" ;;
			esac
		  done   
      
    
         
  
  
done
