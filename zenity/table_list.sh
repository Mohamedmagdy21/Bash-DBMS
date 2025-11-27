#! /usr/bin/bash

# List all tables in a specific Database
if [ -z "$(ls -A ./databases/$DBName)" ]; then
	zenity --info --text="No databases found."
else
	zenity --list \
		--title="Existing Tables" \
		--text="The following Tables are:" \
		--column="Table Name" \
		$(ls -I "*.meta" ./databases/$DBName) \
		--width=400 --height=400
fi