#! /usr/bin/bash

# Delete a specific row based on the pk of that row
# Asks if you want to delete entire row first or not
# If not, the user will have to type the column name he wants to remove
# Then after deleting, will ask if he want to delete another field or not, 
# If not it goes back to the outer loop to ask if he wants to delete another row
# Deleting a field means making it NULL


while true
do

	echo "Enter table you wish to delete from: "
	read table_name
    
	if [ ! -f "./databases/$DBName/$table_name" ]; then
		echo "No table was found."
		continue;
    else
		pk=$(sed -n "/pk$/p" databases/$DBName/$table_name.meta | cut -d: -f1)
		pk_type=$(sed -n "/pk$/p" databases/$DBName/$table_name.meta | cut -d: -f2)
		echo "Table $table_name has Primary Key $pk of Type $pk_type"

		while true; do
			echo "Enter the Primary key of the row you want to delete"
			read pk_delete

			if [ -z "$pk_delete" ]; then
				echo "Error: Primary key cannot be empty."
			elif ! [[ $pk_type == "int" && "$pk_delete" =~ ^[0-9]+$ ]]; then
				echo "Error: Invalid Primary Key. Integers only."
			elif [[ $pk_type == "string" && "$pk_delete" =~ ^[a-zA-Z0-9_]+$ ]]; then
				echo "Error: Invalid Primary Key. Use String and No spaces or special characters allowed."
			else
				# Input is valid
				break
			fi
		done

		echo "Do you want to delete entire row ?"
		select var in "yes" "no"
		do
			case $var in
			yes ) 
				sed -i "/^$pk_delete|/d" databases/$DBName/$table_name
				break;;
			no )

				while true; do
					echo "Enter the column name you want to delete (set to NULL):"
					read col_name

					if [ -z "$col_name" ]; then
						echo "Error: Column Name cannot be empty."
					elif ! [[ "$col_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
						echo "Error: Invalid Column Name. No spaces or special characters allowed."
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
					
					echo "Column '$col_name' (Field #$i) updated to NULL."
				else
					echo "Column name not found!"
				fi
				break;;
			* ) echo "Wrong Choice" ;;
			esac
		done
	fi

	echo "Exit ?"

	select var in "yes" "no"
		do
			case $var in
			yes ) 
				echo "Exiting..."
				break 2;;
			no )
				echo "Continuing..."
				break;;
				
			* ) echo "Wrong Choice" ;;
			esac
		done
      
    
         
  
  
done