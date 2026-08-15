#! /bin/bash

#process monitoring and management tool

#main menu
while true
do 
	echo "Process and Log Magement System"
	echo "==============================="
	echo "1. Display Cpu/Memory Usage and top 10 meoru consume processes"
	echo "2. Terminate Process"
	echo "3. Check disk usage and Find large files than 50MB"
	echo "4. Archive large log files and check Archive size"


	read -p "Enter your choice: " CHOICE

	#select1
	if [ "$CHOICE" = "1" ]
	then 
		echo "Cpu and Memory usage"
		echo "===================="

		#display cpu usage
		echo "Cpu usage: "
		top -bn1 | grep "Cpu(s)"

		#display memory usage
		echo "Memory usage: "
		free -h

		#display top 10 memory usage process
		echo "Top 10 memory consumin process"
		echo "==============================="

		ps -eo pid,user,%cpu,%mem,comm --sort=%mem | head -n 11

	#select2
	
	elif [ "$CHOICE" = "2" ]
	then 
		read -p "Enter the PID of the process: " PID

		#check if process exist
		if ! ps -p "$PID" > /dev/null
		then 
			echo "Process with PID $PID dose not exist."
			continue
		fi

		#prevent termination of pid 1
		if [ "$PID" = "1" ]
		then 
			echo "Error! PID 1 is critical system process."
			echo "Termination is not aloowed."
			continue
		fi

		#get process
		PROCESS_NAME=$(ps -p "$PID" -o comm=)

		#prevent termination of critical process
		if [ "$PROCESS_NAME" = "systemd" ] || [ "$PROCESS_NAME" = "init" ]
		then
			echo "Error! : $PROCESS_NAME is a critical system process."
			echo "Termination is not allowed"
			continue

		fi

		#display process information
		echo "Process information: "
		ps -p "$PID" -o pid,user,%cpu,%mem,comm

		#ask confimation
		read -p "Are you sure you want terminate this process? (y/n): " CONFIRM
		if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]
		then 
			kill "$PID"
			echo " Process $PID has been terminated"

		else
			echo "Process termination cancelled."
		fi

#select3 
	elif [ "$CHOICE" = "3" ]
	then
		read -p "Enter the sensor log directory path: " LOG_DIR

		#check directory
		if [ -d "$LOG_DIR" ]
		then
			echo "========================"
			echo "       DISK USAGE"
			echo "========================"

			du -sh "$LOG_DIR"

		#fin large log files
		echo "LOG file larger than 50 MB"

		LARGE_FILES=$(find "$LOG_DIR" -type f -name "*.log" -size +50M)
		if [ -z "$LARGE_FILES" ]
		then
			echo "No large files larger than 50MB found."
		else
			find "$LOG_DIR" -type f -name "*.log" -size +50M -exec ls -lh {} \;
		fi

	else
		echo "Directory dose not exist."

	fi

#select 4
	elif [ "$CHOICE" = "4" ]
	then 
		read -p "Enter the log directory path: " LOG_DIR

		#check if directory exist
		if [ ! -d "$LOG_DIR" ]
		then
			echo "Directory dose not exist"
			continue
		fi

		#create archiveLogs directory
		if [ ! -d "ArchiveLogs" ]
		then
			mkdir ArchiveLogs
			echo "ArchiveLogs directory created."
		fi

		#find large log files
		LARGE_FILES=$(find "$LOG_DIR" -type f -name "*.log" -size +50M)

		if [ -z "$LARGE_FILES" ]
		then
			echo "No log file than 50MB found."
		else
			#create timestamp
			TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

			#create archive file name
			ARCHIVE_NAME="ArchiveLogs/Logs_$TIMESTAMP.tar.gz"

			echo "compressing large log files..."
			tar -czf "$ARCHIVE_NAME" $LARGE_FILES

			echo "Large log files have been archived."
			echo "Archive files: "
			echo "$ARCHIVE_NAME"
		fi

		#check archive size
		echo "ArchiveLogs Size"
		echo "================"

		du -sh ArchiveLogs

		#archive logs size in bytes
		SIZE=$(du -s -B1 ArchiveLogs | cit -f1)

		#check if larger than 1GB
		if [ "$SIZE" -gt 1073741824 ]
		then 
			echo "WARNING!"
			echo "ArchiveLogs directory is larger than 1GB"
		else
			echo "Archive is in 1GB limit."
		fi

else
	echo "Invalid choice."
	echo "Please select 1, 2, 3, 4, or 5."
fi

done





