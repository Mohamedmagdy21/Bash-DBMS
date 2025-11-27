#! /usr/bin/bash

# Make a new table by entering table name, number of columns
# Then making a table file, and a meta file

# Get input from user and checking for edge cases

while true; do
    table_name=$(zenity --entry --text="Enter Table Name: ")

	if [ $? -ne 0 ]; then return; fi

    if [ -z "$table_name" ]; then
        zenity --error --text="Error: Table Name cannot be empty."
    elif [ -f "./databases/$DBName/$table_name" ]; then
        zenity --error --text="Error: Table Name already exists!"
    elif ! [[ "$table_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        zenity --error --text="Error: Invalid Table Name. No spaces or special characters allowed."
    else
        # Input is valid
        break
    fi
done

while true; do
    col_num=$(zenity --entry --text="Enter Number of Columns: ")

	if [ $? -ne 0 ]; then return; fi

    if [ -z "$col_num" ]; then
        zenity --error --text="Error: Input cannot be empty."
    elif ! [[ "$col_num" =~ ^[0-9]+$ ]]; then
        zenity --error --text="Error: Invalid input. Integers only."
    elif [ "$col_num" -le 0 ]; then
        zenity --error --text="Error: Column number must be greater than 0."
    else
        # Input is valid
        break
    fi
done

# Create table and meta file
touch databases/$DBName/$table_name
touch databases/$DBName/$table_name.meta
pk=""

# Loop over to get Column names and the DataType
for ((i=1; i<$col_num + 1; i++))
    do

        while true; do
            col_name=$(zenity --entry --title="#$i Column" --text="Enter Column Name: ")

			if [ $? -ne 0 ]; then return; fi

            if [ -z "$col_name" ]; then
                zenity --error --text="Error: Column Name cannot be empty."
            elif ! [[ "$col_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
                zenity --error --text="Error: Invalid Column Name. No spaces or special characters allowed."

			# Check for duplicates in the .meta file
            # We use -f to make sure the file exists before trying to read it (avoids error on the very first column)
            elif [ -f "./databases/$DBName/$table_name.meta" ] && cut -d: -f1 "./databases/$DBName/$table_name.meta" | grep -q "$col_name"; then
                zenity --error --text="Error: Column Name '$col_name' already exists!"

            else
                # Input is valid
                break
            fi
        done


		# Data Type
        data_type=$(zenity --list --column="Type" --text="Please choose the data type: " "int" "str")
        
        if [ -z "$data_type" ]; then
             # Default if cancelled
             data_type="str"
        fi

		# Deciding if that Column is the Primary Key
        if [[ $pk == "" ]]; 
        then
            if [[ $i == $col_num  ]]
            then
                zenity --info --text="this is your last column, it will be primary key by default"
                pk="pk"
                echo $col_name:$data_type:pk >> databases/$DBName/$table_name.meta
            
			# Assigning it as primary or no ?
            else
                zenity --question --text="Make it Primary Key ? "
                if [ $? -eq 0 ]; then
                    pk="pk"
                    echo $col_name:$data_type:pk >> databases/$DBName/$table_name.meta
                else
                    echo $col_name:$data_type >> databases/$DBName/$table_name.meta
                fi
            fi
        else
            echo $col_name:$data_type >> databases/$DBName/$table_name.meta
        fi
        
    done


meta_file="./databases/$DBName/$table_name.meta"
# Create a temporary file to store the sorted data
touch "$meta_file.tmp"

# Find the line with 'pk' (case insensitive) and put it first in the temp file
grep -i ":pk$" "$meta_file" >> "$meta_file.tmp"

# Find lines that DO NOT (-v) contain 'pk' and append them to the temp file
grep -v -i ":pk$" "$meta_file" >> "$meta_file.tmp"

# Overwrite the original file with the reordered temp file
mv "$meta_file.tmp" "$meta_file"

row=""
for item in $(cut -d: -f1 "$meta_file"); do
    if [ -z "$row" ]; then
        row="$item"
    else
        row="$row|$item"
    fi
done

# Write the final result to the file
echo "$row" >> "./databases/$DBName/$table_name"
zenity --info --text="Table created successfully"