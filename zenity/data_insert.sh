#! /usr/bin/bash


while true
 do
    if [ -z "$(ls -A ./databases/$DBName)" ]; then
         zenity --error --text="No table was found."
         break;
    fi

    table=$(zenity --list \
        --column="Table Name" \
        $(ls ./databases/$DBName | grep -v .meta$) \
        --text="Enter table you wish to insert in: ")

    if [ -z "$table" ]; then
        break
    fi
    
   if [ ! -f "./databases/$DBName/$table" ]; then
       zenity --error --text="No table was found."
       break;
   else
       row=""
       colsNum=$(grep -v '^$' "./databases/$DBName/$table.meta" | wc -l)
       
       for i in $(seq 1 $colsNum)
         do
         lineContent=$(sed -n "${i}p" < ./databases/$DBName/$table.meta )
         colName=$(echo "$lineContent" | cut -d':' -f1 | tr -d '[:space:]')
         colType=$(echo "$lineContent" | cut -d':' -f2 | tr -d '[:space:]')
         colKey=$(echo "$lineContent" | cut -d':' -f3 | tr -d '[:space:]')
         while true
          do
           isPk=false
           prompt="enter the value for $colName of type $colType "
           if [ "$colKey" == "pk" ]; then
            prompt="$prompt which is a primary key"
            isPk="true"
           fi
			
           input=$(zenity --entry --text="$prompt")

			if [ $? -ne 0 ]; then
                return
            fi

           if [ -z "$input" ]; then
             zenity --error --text="Error: Value cannot be empty."
             continue
           fi  
           if [ "$colType" == "int" ]; then
             
             if ! [[ "$input" =~ ^[0-9]+$ ]]; then
               zenity --error --text="invalid input, input should only be an int"
               continue 
               fi
            fi   
               
           if [ "$colType" == "str" ]; then
           
             if ! [[ "$input" =~ ^[A-Za-z][A-Za-z0-9]*$ ]]; then
              
              zenity --error --text="Invalid input: must begin with a letter and contain only letters or digits"
              continue 
              fi
           fi   
           
           if [ "$isPk" == true ]; then
             # Using grep -q for faster checking than looping
             if grep -q "^$input|" "./databases/$DBName/$table"; then
                 zenity --error --text="Primary key '$input' already exists! "
                 continue 
             fi
            fi     
              
            if [ -z "$row" ]; then
              row="$input"
            else
              row="$row|$input"
            fi

            break  
           done  
         done        
               
       firstEmpty=$(grep -n '^$' ./databases/$DBName/$table | head -1 | cut -d':' -f1 )
       if [ -n "$firstEmpty" ]; then
          sed -i "${firstEmpty}s/^$/$row/" "./databases/$DBName/$table"
       else
           echo "$row" >> "./databases/$DBName/$table"
       fi
    fi
   
    zenity --question --text=" Do you wish to continue ?"
    if [ $? -eq 0 ]; then
       continue
    else
       break
    fi     
  
done