#! /usr/bin/bash

#remove a table by entering its name

while true; do
    echo -n "Enter Table Name: "
    read table_name

    if [ -z "$table_name" ]; then
        echo "Error: Table Name cannot be empty."
    elif ! [[ "$table_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Error: Invalid Table Name. No spaces or special characters allowed."
    elif [ ! -f "./databases/$DBName/$table_name" ]; then
        echo "Table does not exist !"   
        
    else
        # Input is valid
        break
    fi
done

while true; do
    echo
    echo "---------------------------------------------------------"
    echo -n "Are you sure you want to remove this table ? (Y/N)"
    read intent

    if [ "$intent" = "Y" ]; then
	rm databases/$DBName/$table_name
        rm databases/$DBName/$table_name.meta
	break
    elif [ "$intent" = "N" ]; then
        # exit the code
        break
    else
      continue    
        
    fi
done
