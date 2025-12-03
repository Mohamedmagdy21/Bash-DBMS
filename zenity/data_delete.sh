#! /usr/bin/bash

# Delete a specific row based on the pk of that row
# Asks if you want to delete entire row first or not
# If not, the user will have to type the column name he wants to remove
# Then after deleting, will ask if he want to delete another field or not, 
# If not it goes back to the outer loop to ask if he wants to delete another row
# Deleting a field means making it NULL

while true
do
	if [ -z "$(ls -A ./databases/$DBName)" ]; then
         zenity --error --text="No table was found."
         break;
    fi
	
    # Using list for table selection to avoid typing errors
    table_name=$(zenity --list \
        --column="Table Name" \
        $(ls ./databases/$DBName | grep -v .meta$) \
        --text="Enter table you wish to delete from: ")
    
    if [ -z "$table_name" ]; then
        # Handle cancel
        break
    fi
    num_lines=$(wc -l < "./databases/$DBName/$table_name")

	# If lines are 1 (just header) or 0 (empty file), it's empty
	if [ "$num_lines" -le 1 ]; then
		zenity --error --text="Table '$table_name' is empty. No data rows found."
		
		return 
	fi
    if [ ! -f "./databases/$DBName/$table_name" ]; then
        zenity --error --text="No table was found."
        continue;
    else
        pk=$(sed -n "/pk$/p" databases/$DBName/$table_name.meta | cut -d: -f1)
        pk_type=$(sed -n "/pk$/p" databases/$DBName/$table_name.meta | cut -d: -f2)
        zenity --info --text="Table $table_name has Primary Key $pk of Type $pk_type"

        while true; do
            pk_delete=$(zenity --entry --text="Enter the Primary key of the row you want to delete")

			if [ $? -ne 0 ]; then
                break 2
            fi

            if [ -z "$pk_delete" ]; then
                zenity --error --text="Error: Primary key cannot be empty."
            elif [[ $pk_type == "int" && ! "$pk_delete" =~ ^[0-9]+$ ]]; then
                zenity --error --text="Error: Invalid Primary Key. Integers only."
            elif [[ $pk_type == "str" && ! "$pk_delete" =~ ^[a-zA-Z0-9_]+$ ]]; then
                zenity --error --text="Error: Invalid Primary Key. Use String and No spaces or special characters allowed."
            else
                # Input is valid
                break
            fi
        done

        zenity --question --text="Do you want to delete entire row ?"
        
        if [ $? -eq 0 ]; then
            # Yes
            sed -i "/^$pk_delete|/d" databases/$DBName/$table_name
            zenity --info --text="Row deleted successfully"
        else
            # No
            while true; do
                # Get columns for list
                header=$(head -n 1 databases/$DBName/$table_name)
                col_list=$(echo "$header" | tr '|' ' ')

                col_name=$(zenity --list \
                    --column="Column" \
                    $col_list \
                    --text="Enter the column name you want to delete (set to NULL):")

                if [ -z "$col_name" ]; then
                    zenity --error --text="Error: Column Name cannot be empty."
                elif ! [[ "$col_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
                    zenity --error --text="Error: Invalid Column Name. No spaces or special characters allowed."
                else
                    # Input is valid
                    break
                fi
            done
            
            # Column Number
            i=1
            # Found the field that to be deleted or not
            found=0
            
            # Name of Columns
            header=$(head -n 1 databases/$DBName/$table_name)

            # Replace '|' with a space so the loop sees column values
            for item in $(echo "$header" | tr '|' ' '); do
                if [ $item == $col_name ]
                then
                    found=1
                    break
                else
                    i=$((i+1))
                fi

            done
            if [ $found -eq 1 ]; then
                # Get the current value of the specific cell using the column number ($i)
                old_value=$(grep "^$pk_delete|" databases/$DBName/$table_name | cut -d'|' -f$i)

                # Use sed to find the row starting with PK, and replace old_value with NULL
                sed -i "/^$pk_delete|/ s/$old_value/NULL/" databases/$DBName/$table_name
                
                zenity --info --text="Column '$col_name' (Field #$i) updated to NULL."
            else
                zenity --error --text="Column name not found!"
            fi
        fi
    fi

    zenity --question --text="Exit ?"
    if [ $? -eq 0 ]; then
        echo "Exiting..."
        break
    else
        echo "Continuing..."
    fi
      
done