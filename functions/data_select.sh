#! /usr/bin/bash

# NOTE FOR YOU: use that command for beautiful printing
# sed 's/|/ | /g' filename.txt | column -t -s '|'

# three modes of selection :
# 1-select all table
# 2-select a specific column
# 3- select a specific row
# >>>>>>>>>>>> record all selection during single entry to a specific existent database
#----------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------


entry=0
declare -a output 

while true
 do
 clear
 
 
 
 entry=$((entry+1))
 
 echo "This your $entry entry"
 
 echo "-----------------------------------------------"
 
 
 echo -e "Enter table's name : \n "

 read table
if [[ "$table" =~ [^a-zA-Z0-9_] ]]; then
    echo "Error: Table name '$table' contains special characters or spaces. Only letters, numbers, and underscores are allowed."
	echo "---------------------------------------------"
	echo " Exit this selection?"
	echo "---------------------------------------------"


	select var in "yes" "no"                 # exit and return back to the previous menu
	do
		case $var in
		yes ) 
			echo "Exiting..."
			unset output
			break 2 ;;
		no )
			echo "Continuing..."
			continue 2;;
			
		* ) echo "Wrong Choice" ;;
		esac
	done
elif [ ! -f "./databases/$DBName/$table" ]; then        # check availability of the table
	echo
	echo "No table was not found."
	#break;
	
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
			break 2 ;;
		no )
			echo "Continuing..."
			continue 2;;
			
		* ) echo "Wrong Choice" ;;
		esac
	done
	
fi

 
 header=$(awk -F':' '{print $1}' ./databases/$DBName/$table.meta | paste -sd'|' -)  
 
pkLine=$(awk -F: '$3=="pk" {print NR}' "./databases/$DBName/$table.meta")    # extract the primary key line number
echo "Primary key is on column $pkLine"


 
 
 
echo
echo "---------------------------------------------"
echo " Choose an option:"
echo "---------------------------------------------"
echo " 1) Select ALL rows"
echo " 2) Select a specific COLUMN"
echo " 3) Select a specific ROW (pk)"
echo " 4) View saved entries & exit"
echo "---------------------------------------------"
echo

 
 read userChoice
 
 case "$userChoice" in
 
 
  1)  
    result="$(column -t -s '|' "./databases/$DBName/$table")"   # select all table
    echo "$result"
    output[$entry]="$result >>>>>>>>>>>> from table ./databases/$DBName/$table , SELECT ALL"
    ;;
      
  
  2) 
     echo "enter the name of the column you wish to select:"         # select whole column
     read colName
     
        if ! echo "$header" | tr '|' '\n' | grep -qx "$colName"; then   # check if column exists
           echo
           echo "Column '$colName' does NOT exist!"
           
           #---------------------------------------------------------------------------------
           
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

           
           
           
           
           
           
           #--------------------------------------------------------------------------------- 
           continue
        fi
        
        

        # Split into array
        IFS='|' read -r -a columns <<< "$header"

        # Find column index
        colIndex=-1
        for i in "${!columns[@]}"; do
          if [[ "${columns[$i]}" == "$colName" ]]; then
            colIndex=$((i+1))  # cut is 1-indexed
            break
          fi
       done
      echo "------------------------------------------------------------------------------"
      echo "$colName : column number: $colIndex"
      echo "------------------------------------------------------------------------------"
      #selected=$(cut -d '|' -f"$colIndex" "./databases/$DBName/$table" | column -t -s '|')
      selected=$(cut -d '|' -f"$colIndex" "./databases/$DBName/$table" \
    | tail -n +2 \
    | column -t -s '|')

      echo "$selected" 
      output[$entry]="$selected >>>>>>>>>>>> from table ./databases/$DBName/$table , SELECT COLUMN $colName"   
        ;;            # whole column display
      
        
   3) 
      echo "enter the pk value of the line you wish to select:"   # select a specific row
      read value
      found=false
      numRows=$(wc -l < ./databases/$DBName/$table)   # count the number of rows
      for i in $(seq 1 $numRows); 
        do
         line=$(sed -n "${i}p" ./databases/$DBName/$table )
         val=$(echo "$line" | cut -d'|' -f"$pkLine")       # extract value in  the primary key's field only 
         
         if [ "$val" == "$value" ]; then
           echo "Match found in row $(($i - 1)):"
           echo "$line"
           output[$entry]="$line >>>>>>>>>>>> from table ./databases/$DBName/$table"
           found=true
           break 
         fi
         
        done        
        if [ "$found" == false ]; then
        
          echo "Match not found" 
          
          #-----------------------------------------------------------------------------------
          
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

          
          
          
          
          
          
          #------------------------------------------------------------------------------------
          continue
          
         
       fi   ;;
  
    4) 
       if [ ${#output[@]} -ne 0 ]; then      # exit and print history of selection during this one entry to that database
         echo "Previous entries:"
            for i in "${!output[@]}"; do
              echo "----------------------------------------------------------------------"
              echo "Entry $i -> ${output[$i]}"
            done
       else
         echo "No entries yet."
       fi
       unset output
       break;;
   
  
 esac
  
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
