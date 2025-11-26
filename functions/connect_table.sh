#! /usr/bin/bash

PS3="DMS>>"

PS3="DMS>>"


while true
 do
 clear
 echo "Enter 1 to create table :"
 echo "Enter 2 to List table:"
 echo "Enter 3 to drop table:"
 echo "Enter 4 to insert into table:"
 echo "Enter 5 to select from table:"
 echo "enter 6 to update table:"
 echo "enter 7 to delete from table:"
 echo -e "\n"
 echo -e "Enter your selection \c"
 
  read option

  case "$option" in
  1) source ./functions/table_create.sh;;
  
  2)echo "--- Existing Databases ---"
    echo "Enter table you wish to list: "
      read table
       if [ -z "$(ls -A ./databases/$DBName/$table)" ]; then
           echo "No table was found."
       else
           # FIX: Lists directories only and removes the trailing slash
           ls -l ./databases/$DBName/$table
       fi
       echo "--------------------------"
       ;;
       
    3) source ./functions/table_drop.sh;;
    
    4) source ./functions/data_insert.sh;;
       
    5) source ./functions/data_select.sh;;
    
    6) source ./functions/data_update.sh;;

	7) source ./functions/data_delete.sh;;
  
  esac
  echo -e "enter return to continue \c"
  read inp

done
