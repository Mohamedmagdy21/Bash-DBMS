#! /usr/bin/bash

#remove a table by entering its name

if [ -z "$(ls -A ./databases/$DBName | grep -v .meta$)" ]; then
    zenity --error --text="No table was found."
    return
fi

table_name=$(zenity --list \
	--title="Existing Tables" \
    --column="Table Name" \
    $(ls ./databases/$DBName | grep -v .meta$) \
    --width=400 --height=400)

if [ -z "$table_name" ]; then
    return
fi

zenity --question --text="Are you sure you want to remove this table ?"

if [ $? -eq 0 ]; then
    rm databases/$DBName/$table_name
    rm databases/$DBName/$table_name.meta
    zenity --info --text="Table Removed"
else
    # exit the code
    return
fi