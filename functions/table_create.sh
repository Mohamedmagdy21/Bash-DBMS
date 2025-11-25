#! /usr/bin/bash
# Make a new table by entering table name, number of columns
# Then making a table file, and a meta file

# Get input from user and checking for edge cases
while true; do
    echo -n "Enter Table Name: "
    read table_name

    if [ -z "$table_name" ]; then
        echo "Error: Table Name cannot be empty."
    elif [ -f "./databases/student/$table_name" ]; then
        echo "Error: Table Name already exists!"
    elif ! [[ "$table_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Error: Invalid Table Name. No spaces or special characters allowed."
    else
        # Input is valid
        break
    fi
done

while true; do
    echo -n "Enter Number of Columns: "
    read col_num

    if [ -z "$col_num" ]; then
        echo "Error: Input cannot be empty."
    elif ! [[ "$col_num" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid input. Integers only."
    elif [ "$col_num" -le 0 ]; then
        echo "Error: Column number must be greater than 0."
    else
        # Input is valid
        break
    fi
done




# Create table and meta file
touch databases/student/$table_name
touch databases/student/$table_name.meta
pk=""

# Loop over to get Column names and the DataType
for ((i=1; i<$col_num + 1; i++))
    do
        # Column Number
        

        while true; do
            echo "#$i Column"
            echo -n "Enter Column Name: "
            read col_name

            if [ -z "$col_name" ]; then
                echo "Error: Column Name cannot be empty."
            elif ! [[ "$col_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
                echo "Error: Invalid Column Name. No spaces or special characters allowed."

            # Check for duplicates in the .meta file
            # We use -f to make sure the file exists before trying to read it (avoids error on the very first column)
            elif [ -f "./databases/student/$table_name.meta" ] && cut -d: -f1 "./databases/student/$table_name.meta" | grep -q "$col_name"; then
                echo "Error: Column Name '$col_name' already exists!"

            else
                # Input is valid
                break
            fi
        done

        # Data Type
        echo "Please choose the data type: "
        select var in "int" "str"
        do
            case $var in
                int ) data_type="int";break;;
                str ) data_type="str";break;;
                * ) echo "Wrong Choice" ;;
            esac
        done

        # Deciding if that Column is the Primary Key


        if [[ $pk == "" ]]; 

        then
            if [[ $i == $col_num  ]]
            then
                echo "this is your last column, it will be primary key by default"
				pk="pk"
				echo $col_name:$data_type:pk >> databases/student/$table_name.meta
            
            # Assigning it as primary or no ?
			else
				echo -e "Make it Primary Key ? "
				select var in "yes" "no"
					do
						case $var in
						yes ) 
							pk="pk"
							echo $col_name:$data_type:pk >> databases/student/$table_name.meta
						break;;
						no )
							echo $col_name:$data_type >> databases/student/$table_name.meta
						break;;
						* ) echo "Wrong Choice" ;;
						esac
					done
			fi
        else
            echo $col_name:$data_type >> databases/student/$table_name.meta
        fi
        
    done


meta_file="./databases/student/$table_name.meta"
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
echo "$row" >> "./databases/student/$table_name"