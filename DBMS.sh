#!/bin/bash


mkdir DBMS 2> /dev/null

function dbMenu {

echo "********Main Menu********"
echo "*1.Create Database      *" 
echo "*2.List Database        *"
echo "*3.Connect TO Database  *"
echo "*4.Drop Database        *"
echo "*5.EXIT                 *"
echo "*************************"
read -p "enter your choice: " choice
  
	       case $choice in
		1) createDB ;;	
		2) listDB ;;
		3) connectToDB ;;
		4) dropDB ;;
		5) echo "Goodbye!" 
			exit ;;
		*) echo $choice is not an option ; dbMenu ;
	        	
               esac 
}

 # This function will allow user to create databases.
function createDB {  

	echo -e "Enter Database Name: \c"
	read dbName
	mkdir ./DBMS/$dbName 2> /dev/null 
	
        #condition to check exit status
	# =0 then normal execution, else failing to create DB
	if [[ $? == 0 ]] 
	then
		echo "$dbName created successfully"
	else
		echo "Error creating $dbName, already exists"
	fi
	dbMenu
}

# Function to list created DB's
function listDB {
	#Condition to check if DB is empty or not
	if [ "$(ls ./DBMS)" ]; then		
	echo "Existing Databases are:"
	ls -1 ./DBMS
	dbMenu
	else
	echo "No Databases Avaliable, You Need To Create One First"
	dbMenu
	fi
}

function tableMenu {

echo "*******Table Menu********"
echo "*1.Create Table         *" 
echo "*2.List Tables          *"
echo "*3.Drop Table           *"
echo "*4.Insert Into Table    *"
echo "*5.Select From Table    *"
echo "*6.Delete From Table    *"
echo "*7.Update Table         *"
echo "*8.EXIT                 *"
echo "*************************"
read -p "enter your choice: " choice
               
               case $choice in
                1) createTable ;;
                2) listTables ;;
                3) dropTable ;;
                4) insertIntoTable ;;
                5) selectFromTable ;;
                6) deleteFromTable ;;
                7) updateTable ;;
		8) echo "Goodbye!" 
			exit;;
                *) echo $choice is not an option ; tableMenu;

               esac
}

 # Function to connect to DB and will let you use the table menu options
 function connectToDB {
  echo "Here's A List Of Your Databases: "
  ls -1 ./DBMS

  #Loop to check if the user entered a name to DB or not and whether if user entered an existing DB name or not
  while true; do
    read -p "Database name to connect to: " dbName

    #Condition to make sure that the user entered a name to the DB
    if [ -z "$dbName" ]; then
      echo "Error:Can not be empty, enter a name: "

    #Condition to check if the DB exists or not
    elif [ ! -d "./DBMS/$dbName" ]; then
      echo "Database $dbName doesn't exist, please choose from the following: "
      ls ./DBMS
    else
      cd "./DBMS/$dbName"
      echo "Options to do on Database $dbName :"
      tableMenu
    fi
  done
}

#This function allows the user to delete the whole DB from the system
function dropDB {
  echo "Here's A List Of Your Databases: "
  ls -1 ./DBMS

  #Loop to check if the user entered a name to DB or not and whether if user entered an existing DB name or not
  while true; do
    read -p "Enter Database Name You Want To Drop: " dbName
	
    #condition to check whether DB empty or not
    if [ -z "$dbName" ]; then
      echo "Error:can not be empty, enter a name: "

    #condition to check if DB you entered to delete exists or not  
    elif [ ! -d "./DBMS/$dbName" ]; then
      echo "Database $dbName does not exist, Please choose from the following:"
    else
      break
    fi
  done

  #Confirming if the user wants to delete the specified DB or not
  read -p "Are you sure you want to delete the database $dbName? (y/n): " reply

  if [ "$reply" == "y" ]; then
    rm -r "./DBMS/$dbName" 2>/dev/null

    #if execution done normally
    if [[ $? == 0 ]]; then
      echo "Database $dbName is deleted successfully"
    else
      echo "Error: Unable to delete database $dbName"
    fi
  else
    #if user pressed no while confirmation the deletion will be canceled
    echo "Deletion canceled"
  fi

  dbMenu
}

#This function allows user to create tables inside the DB system as files inside the directory

function createTable {
read -p "Enter The Name Of The Table: " tableName

#condition to check whether table file or it's medatadata file exists
if [ -f "$tableName" ] || [ -f ".$tableName.metadata" ]
then
    echo "Table Already Exists"
    exit
fi

read -p "Enter the number of columns: " colsNum

#Create table file and it's metadata file
touch ".$tableName.metadata"
touch "$tableName"

counter=1
while [ $counter -le $colsNum ]
do
    #loop to ask the user to enter column name until he entered a valid one	
    while true
    do
        read -p "Enter the name of column $counter: " colName

        #condition to check whether user entered a column name or not
        if [ -z "$colName" ]; then
  	      echo "Error:can not be empty"  	
       	      continue  
        else
	      break
	fi
    done

    #loop to ask a user to enter column type until he entered a valid one ( int-string )
    while true
    do
        echo "Choose The Type Of Column $counter: "
        PS3="Select an option (1-$colsNum): "
        select colType in "int" "str"
        do
            case $colType in 	
                "int" | "str" ) break ;;
                *) echo "Wrong Choice" ;;
            esac
        done
        break
    done

    #we will append the column name and type to the metadata file
    echo "$colName:$colType" >> .$tableName.metadata

    #we will append the column name to the table file
    echo -n "$colName " >> $tableName

    ((counter++))
done

#we will append a new line to the table file      
echo >> $tableName

#we will ask the user to choose the field he wants to be the primary key 
pk=false
while [ "$pk" = false ]
do
    echo "Choose the primary key: "
    ps3="Select an option: (1-$colsNum): "

    #the user will select the primary key from 1st field in table metadata which contains (fields) as the 1st field and (types) as the 2nd field
    select primaryKey in $(cut -d: -f1 ".$tableName.metadata")
    do
        if [ -n "$primaryKey" ]; then
            echo "$primaryKey:primarykey" >> ".$tableName.metadata"
            pk=true
            break
        else
            echo "Wrong Choice"
        fi
    done
done
echo "Table $tableName Created Successfully"
exit

}

#Function to allow user to delete a certain table(file) from the DB

function dropTable {
	ls -1 /home/salma01/DBMS/$dbName
	read -p "Enter Table Name You Want To Delete: " tableName
 
 #changing directory to check if the name of the table(file) exists in order to delete it or generate an error if the file is not found   
	
        cd /home/salma01/DBMS/$dbName

if [ -f "$tableName" ] || [ -f ".$tableName.metadata" ];
	then
    	rm  $tableName 
	rm .$tableName.metadata
	echo "Table Deleted Successfully"	
	else
	echo "Nothing to delete"
	
fi
	tableMenu
}