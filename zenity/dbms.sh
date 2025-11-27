#! /usr/bin/bash

mkdir -p ./databases   # Create Database directory if not exists


while true; do
    option=$(zenity --list \
        --title="DBMS Main Menu" \
        --text="Select an operation:" \
        --column="ID" --column="Operation" \
        1 "Create Database" \
        2 "List Databases" \
        3 "Connect to Database" \
        4 "Drop Database" \
        --height=400 --width=400 \
        --hide-header=FALSE)

    # Check if user clicked Cancel or closed the window
    if [ -z "$option" ]; then
        break
    fi

    case "$option" in
    
    1)
        input=$(zenity --entry --title="Create Database" --text="Enter the name of the new database:")
        
        # Check if user cancelled input
        if [ $? -ne 0 ]; 
			then 
			continue
		fi

        if [ -z "$input" ]; then
            zenity --error --text="Input cannot be empty."
        elif [ -d "./databases/$input" ]; then
            zenity --error --text="Error: Database '$input' already exists!"
        elif [[ ! "$input" =~ ^[a-zA-Z0-9_]+$ ]]; then
            zenity --error --text="Error: Invalid name.\nNo spaces or special characters allowed."
        else
            mkdir "./databases/$input"
            zenity --info --text="Database '$input' created successfully."
        fi;;


    2)
        if [ -z "$(ls -A ./databases)" ]; then
           zenity --info --text="No databases found."
       else
           zenity --list \
             --title="Existing Databases" \
             --text="The following databases exist:" \
             --column="Database Name" \
             $(ls -F ./databases | grep / | sed 's/\///g') \
             --width=400 --height=400
       fi
       ;;


    3)
        if [ -z "$(ls -A ./databases)" ]; then
            zenity --error --text="No databases available to connect."
        else
            # Show a list of actual folders to pick from (No typing errors!)
            # Get the list of folders inside ./databases
            DBName=$(zenity --list --title="Connect" --text="Select Database:" --column="Database Name" $(ls ./databases))
            
            if [ -n "$DBName" ]; then
                source ./zenity/connect_table.sh
            fi
        fi
        ;;

    # --- DROP DATABASE ---
    4)
		# Check if the output of ls is NOT empty (-n)
        if [ -n "$(ls ./databases)" ]
		then
            # Select from list instead of typing
            todrop=$(zenity --list --title="Drop Database" --text="Select Database to DELETE:" --column="Database Name" $(ls ./databases))
            
            if [ -n "$todrop" ]; then
                # Safety Confirmation
                zenity --question --text="Are you sure you want to PERMANENTLY delete '$todrop'?"
                
                if [ $? -eq 0 ]; then
                    rm -r "./databases/$todrop"
                    zenity --info --text="Database '$todrop' dropped successfully."
                else
                    zenity --info --text="Deletion cancelled."
                fi
            fi
        else
			zenity --error --text="No databases available to drop."
        fi
		;;

    # --- EXIT ---
    *)
        break
        ;;
    esac

done