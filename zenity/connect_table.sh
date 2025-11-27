#! /usr/bin/bash

while true
 do
  option=$(zenity --list \
        --title="$DBName Main Menu" \
        --text="Select an operation:" \
        --column="ID" --column="Operation" \
        1 "Create Table" \
        2 "List Table" \
        3 "Drop Table" \
        4 "Insert into Table" \
		5 "Select from Table" \
		6 "Update Table" \
		7 "Delete from Table"\
        --height=400 --width=400 \
        --hide-header=FALSE)

  # Check if user cancelled or closed the window
  if [ -z "$option" ]; then
      break
  fi

  case "$option" in
  	1) source ./zenity/table_create.sh;;
  
  	2) source ./zenity/table_list.sh ;;

    3) source ./zenity/table_drop.sh;;
    
    4) source ./zenity/data_insert.sh;;
       
    5) source ./zenity/data_select.sh;;
    
    6) source ./zenity/data_update.sh;;

    7) source ./zenity/data_delete.sh;;
  
  esac
  
  # Note: I removed 'read inp'. 
  # In a GUI, the loop immediately goes back to the Main Menu, 
  # which waits for the user anyway.
done