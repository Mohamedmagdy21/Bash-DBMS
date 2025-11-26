#! /usr/bin/bash

# Update a specific field by asking about table name, Then pk(to get which row to update), Then the name of the column
# Lastly, ask what will be the new value


while true
do

	echo "Enter table you wish to Update from: "
	read table_name
    
	if [ ! -f "./databases/$DBName/$table_name" ]; then
		echo "No table was found."
		continue;
    else
		pk=$(sed -n "/pk$/p" databases/$DBName/$table_name.meta | cut -d: -f1)
		pk_type=$(sed -n "/pk$/p" databases/$DBName/$table_name.meta | cut -d: -f2)
		echo "Table $table_name has Primary Key $pk of Type $pk_type"

		while true; do
			echo "Enter the Primary key of the row you want to Update"
			read pk_update

			if [ -z "$pk_update" ]; then
				echo "Error: Primary key cannot be empty."
			elif [[ $pk_type == "int" && ! "$pk_update" =~ ^[0-9]+$ ]]; then
				echo "Error: Invalid Primary Key. Integers only."
			elif [[ $pk_type == "str" && ! "$pk_update" =~ ^[a-zA-Z0-9_]+$ ]]; then
				echo "Error: Invalid Primary Key. Use String and No spaces or special characters allowed."
			else
				# Input is valid
				break
			fi
		done

		while true; 
		do
			echo "Enter the column name you want to Update:"
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
		if [[ $col_name ==  $pk ]]
		then
			echo "You are updating the value of Primary Key, Make sure its Unique"
			echo "Table $table_name has Primary Key $pk of Type $pk_type"
			value_type=$pk_type
			while true; do
				echo "Enter the new value"
				read value
				if [ -z "$value" ]; then
					echo "Error: New Value cannot be empty."
				elif [[ $value_type == "int" && ! "$value" =~ ^[0-9]+$ ]]; then
					echo "Error: Invalid New Value. Integers only."
				elif [[ $value_type == "str" && ! "$value" =~ ^[a-zA-Z0-9_]+$ ]]; then
					echo "Error: Invalid New Value. Use String and No spaces or special characters allowed."
				# Check for unique
				elif grep -q "^$value|" "databases/$DBName/$table_name"; then
    				echo "Error: Value '$value' already exists. Primary Key must be unique."
				else
					# Input is valid
					break
				fi
			done
		else
			value_type=$(sed -n "/^$col_name:/p" databases/$DBName/$table_name.meta | cut -d: -f2)
			echo "The Datatype of Column $col_name is $value_type"
			while true; do
				echo "Enter the new value"
				read value
				if [ -z "$value" ]; then
					echo "Error: New Value cannot be empty."
				elif [[ $value_type == "int" && ! "$value" =~ ^[0-9]+$ ]]; then
					echo "Error: Invalid New Value. Integers only."
				elif [[ $value_type == "str" && ! "$value" =~ ^[a-zA-Z0-9_]+$ ]]; then
					echo "Error: Invalid New Value. Use String and No spaces or special characters allowed."
				else
					# Input is valid
					break
				fi
			done
		fi

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
		# Get the current value of the specific cell using the column number ($i)
		old_value=$(grep "^$pk_update|" databases/$DBName/$table_name | cut -d'|' -f$i)

		# If the values are the same, then don't update the table
		if [[ $old_value == $value ]]
		then
			echo "Old value is the same as new value $value"
		else
			if [ $found -eq 1 ]; then
				# Use sed to find the row starting with PK, and replace old_value with new value
				sed -i "/^$pk_update|/ s/$old_value/$value/" databases/$DBName/$table_name
				
				echo "Column '$col_name' (Field #$i) Old value $old_value updated to $value."
			else
				echo "Column name not found!"
			fi
		fi	
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