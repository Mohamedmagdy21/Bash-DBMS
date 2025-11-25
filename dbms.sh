
mkdir -p ./databases   #Create Database if not exits
PS3="DMS>>"


while true
 do
 clear
 echo "Enter 1 to create Database :"
 echo "Enter 2 to List table:"
 echo "Enter 3 to connect to Database:"
 echo "Enter 4 to Drop Database:"
 echo "Enter q to exit:"
 echo -e "\n"
 echo -e "Enter your selection \c"

 read option

  case "$option" in
  1) echo "enter the name of the database please :"
         read input
         if [ -z "$input" ]; then
            echo "Input cannot be empty"
         elif [ -d "./databases/$input" ]; then
            echo "Error: Database already exists!"
         elif ! [[ "$input" =~ ^[a-zA-Z0-9_]+$ ]]; then
            echo "Error:Invalid name. No spaces or special characters allowd."
         else
            mkdir "./databases/$input"
         fi;;
  2) echo "--- Existing Databases ---"
       if [ -z "$(ls -A ./databases)" ]; then
           echo "No databases found."
       else
           # FIX: Lists directories only and removes the trailing slash
           ls -F ./databases | grep / | sed 's/\///g';
       fi
       echo "--------------------------"
       ;;


  3) echo "Enter the database you want to connect to:"
        read input
         if [ -z "$input" ]; then
            echo "Input cannot be empty"
         elif [ -d "./databases/$input" ]; then
           DBName="$input"
           source ./functions/connect_table.sh
         else
            echo "Database does not exist yet!"
         fi;;     
         
  
  
  

  4) echo "enter the database you wish to drop:"
   read todrop
   if [ -d "./databases/$todrop" ]; then
      rm -r "./databases/$todrop"
      echo "Database '$todrop' dropped successfully"
   else
      echo "Error:database not found"
   fi ;;                    
                  
  q) exit;
  esac
  echo -e "enter return to continue \c"
  read inp
done













