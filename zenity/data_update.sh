#! /usr/bin/bash

# Update a specific field by asking about table name, Then pk(to get which row to update), Then the name of the column
# Lastly, ask what will be the new value

while true
do
	if [ -z "$(ls -A ./databases/$DBName)" ]; then
         zenity --error --text="No table was found."
         break;
    fi

    table_name=$(zenity --list \
        --column="Table Name" \
        $(ls ./databases/$DBName | grep -v .meta$) \
        --text="Enter table you wish to Update from: ")
    
    if [ $? -ne 0 ]; then
                break 2
    fi
    
    if [ ! -f "./databases/$DBName/$table_name" ]; then
        zenity --error --text="No table was found."
        continue;
    else
        pk=$(sed -n "/pk$/p" databases/$DBName/$table_name.meta | cut -d: -f1)
        pk_type=$(sed -n "/pk$/p" databases/$DBName/$table_name.meta | cut -d: -f2)
        zenity --info --text="Table $table_name has Primary Key $pk of Type $pk_type"

        while true; do
            pk_update=$(zenity --entry --text="Enter the Primary key of the row you want to Update")

			if [ $? -ne 0 ]; then break 2; fi

            if [ -z "$pk_update" ]; then
                zenity --error --text="Error: Primary key cannot be empty."
            elif [[ $pk_type == "int" && ! "$pk_update" =~ ^[0-9]+$ ]]; then
                zenity --error --text="Error: Invalid Primary Key. Integers only."
            elif [[ $pk_type == "str" && ! "$pk_update" =~ ^[a-zA-Z0-9_]+$ ]]; then
                zenity --error --text="Error: Invalid Primary Key. Use String and No spaces or special characters allowed."
            elif ! grep -q "^$pk_update|" "./databases/$DBName/$table_name"; then
                 zenity --error --text="Error: Row not found."
            else
                # Input is valid
                break
            fi
        done

        while true; 
        do
            header=$(head -n 1 databases/$DBName/$table_name)
            col_list=$(echo "$header" | tr '|' ' ')
            
            col_name=$(zenity --list --column="Column" $col_list --text="Enter the column name you want to Update:")

			if [ $? -ne 0 ]; then break 2; fi

            if [ -z "$col_name" ]; then
                zenity --error --text="Error: Column Name cannot be empty."
            elif ! [[ "$col_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
                zenity --error --text="Error: Invalid Column Name. No spaces or special characters allowed."
            else
                # Input is valid
                break
            fi
        done
        
        if [[ $col_name ==  $pk ]]
        then
            zenity --warning --text="You are updating the value of Primary Key, Make sure its Unique"
            value_type=$pk_type
            while true; do
                value=$(zenity --entry --text="Enter the new value")

				if [ $? -ne 0 ]; then break 2; fi

                if [ -z "$value" ]; then
                    zenity --error --text="Error: New Value cannot be empty."
                elif [[ $value_type == "int" && ! "$value" =~ ^[0-9]+$ ]]; then
                    zenity --error --text="Error: Invalid New Value. Integers only."
                elif [[ $value_type == "str" && ! "$value" =~ ^[a-zA-Z0-9_]+$ ]]; then
                    zenity --error --text="Error: Invalid New Value. Use String and No spaces or special characters allowed."
                elif grep -q "^$value|" "databases/$DBName/$table_name"; then
                    zenity --error --text="Error: Value '$value' already exists. Primary Key must be unique."
                else
                    # Input is valid
                    break
                fi
            done
        else
            value_type=$(sed -n "/^$col_name:/p" databases/$DBName/$table_name.meta | cut -d: -f2 | tr -d '[:space:]')
            zenity --info --text="The Datatype of Column $col_name is $value_type"
            while true; do
                value=$(zenity --entry --text="Enter the new value")

				if [ $? -ne 0 ]; then break 2; fi

                if [ -z "$value" ]; then
                    zenity --error --text="Error: New Value cannot be empty."
                elif [[ $value_type == "int" && ! "$value" =~ ^[0-9]+$ ]]; then
                    zenity --error --text="Error: Invalid New Value. Integers only."
                elif [[ $value_type == "str" && ! "$value" =~ ^[a-zA-Z0-9_]+$ ]]; then
                    zenity --error --text="Error: Invalid New Value. Use String and No spaces or special characters allowed."
                else
                    # Input is valid
                    break
                fi
            done
        fi

        i=1
        found=0
        
        header=$(head -n 1 databases/$DBName/$table_name)

        for item in $(echo "$header" | tr '|' ' '); do
            if [ $item == $col_name ]
            then
                found=1
                break
            else
                i=$((i+1))
            fi

        done

        old_value=$(grep "^$pk_update|" databases/$DBName/$table_name | cut -d'|' -f$i)

        if [[ $old_value == $value ]]
        then
            zenity --info --text="Old value is the same as new value $value"
        else
            if [ $found -eq 1 ]; then
                sed -i "/^$pk_update|/ s/$old_value/$value/" databases/$DBName/$table_name
                
                zenity --info --text="Column '$col_name' (Field #$i) Old value $old_value updated to $value."
            else
                zenity --error --text="Column name not found!"
            fi
        fi  
    fi

    zenity --question --text="Exit ?"

    if [ $? -eq 0 ]; then
        echo "Exiting..."
        break 2
    else
        echo "Continuing..."
    fi
  
done