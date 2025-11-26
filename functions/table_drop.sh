#! /usr/bin/bash

#remove a table by entering its name

while true; do
    echo -n "Enter Table Name: "
    read table_name

    if [ -z "$table_name" ]; then
        echo "Error: Table Name cannot be empty."
    elif ! [[ "$table_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Error: Invalid Table Name. No spaces or special characters allowed."
    else
        # Input is valid
        break
    fi
done

while true; do
    echo -n "Are you sure you want to remove this table ?"
    read intent

    if [ $intent == "yes" ]; then
		rm databases/$DBName/$table_name
        rm databases/$DBName/$table_name.meta
		break
    else
        # exit the code
        break
    fi
done
