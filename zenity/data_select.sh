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
 
 entry=$((entry+1))

 if [ -z "$(ls -A ./databases/$DBName)" ]; then        # check availability of the table
		   zenity --error --text="No table was found."
           break;
 fi

 table=$(zenity --list \
		--title="This your $entry entry" \
        --column="Table Name" \
        $(ls ./databases/$DBName | grep -v .meta$) \
        --text="Select table's name: ")

 num_lines=$(wc -l < "./databases/$DBName/$table")

 # If lines are 1 (just header) or 0 (empty file), it's empty
 if [ "$num_lines" -le 1 ]; then
	 zenity --error --text="Table '$table' is empty. No data rows found."
	
	 return 
 fi
 
 header=$(awk -F':' '{print $1}' ./databases/$DBName/$table.meta | paste -sd'|' -)  
 
pkLine=$(awk -F: '$3=="pk" {print NR}' "./databases/$DBName/$table.meta")    # extract the primary key line number

 
option=$(zenity --list \
        --title="Choose an option:" \
        --text="Select an operation:" \
        --column="Number" --column="Operation" \
        1 "Select ALL rows" \
        2 "Select a specific COLUMN" \
        3 "Select a specific ROW (pk)" \
        4 "View saved entries & exit" \
        --height=400 --width=400 \
        --hide-header=FALSE)
 
 case "$option" in
 
 
  1)  
    result="$(column -t -s '|' "./databases/$DBName/$table")"   # select all table
    echo "$result" | zenity --text-info \
       --width=600 --height=400 \
       --font="Monospace" \
       --editable=FALSE
    output[$entry]="$result >>>>>>>>>>>> from table ./databases/$DBName/$table , SELECT ALL"
    ;;
      
  
  2) 
	 colName=$(zenity --entry --text="enter the name of the column you wish to select:")	# select whole column

     
        if ! echo "$header" | tr '|' '\n' | grep -qx "$colName"; then   # check if column exists
		   zenity --error --text="$colName' does NOT exist!"
           break
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

      selected=$(cut -d '|' -f"$colIndex" "./databases/$DBName/$table" | column -t -s '|')

	  echo "$selected" | zenity --text-info \
       --width=600 --height=400 \
       --font="Monospace" \
       --editable=FALSE
      output[$entry]="$selected >>>>>>>>>>>> from table ./databases/$DBName/$table , SELECT COLUMN $colName"   
        ;;            # whole column display
      
        
   3) 
	  value=$(zenity --entry --text="enter the pk value of the line you wish to select:")	# select a specific row

      found=false
      numRows=$(wc -l < ./databases/$DBName/$table)   # count the number of rows
      for i in $(seq 1 $numRows); 
        do
         line=$(sed -n "${i}p" ./databases/$DBName/$table )
         val=$(echo "$line" | cut -d'|' -f"$pkLine")       # extract value in  the primary key's field only 
         
         if [ "$val" == "$value" ]; then
			echo "$line" | zenity --text-info \
			--title="Match found in row $i:" \
			--width=600 --height=400 \
			--font="Monospace" \
			--editable=FALSE

           output[$entry]="$line >>>>>>>>>>>> from table ./databases/$DBName/$table"
           found=true
           break 
         fi
         
        done        
        if [ "$found" == false ]; then
        
		  zenity --error --text="Match not found."
          continue
          
         
       fi   ;;
  
    4) 
       if [ ${#output[@]} -ne 0 ]; then      # exit and print history of selection during this one entry to that database
			history_text=""

			for i in "${!output[@]}"; do
				# \n represents a new line
				history_text+="Entry $i\n-> ${output[$i]}\n"
				history_text+="----------------------------------------------------------------------\n"
			done

			# 3. Display the full string in a scrollable window
			# echo -e interprets the \n as actual new lines
			echo -e "$history_text" | zenity --text-info \
				--title="Selection History" \
				--width=600 --height=400
				
       else
         zenity --info --text="No entries yet."
       fi
       unset output
       break;;
       
    
    
   
 
  
 esac
  
 zenity --question --text=" Do you wish to continue ?"
    if [ $? -eq 0 ]; then
       continue
    else
       break
    fi     

 
done           
