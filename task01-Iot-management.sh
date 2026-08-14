#! /bin/bash

#process monitoring and management tool
echo "====== Process Monitoring Tool ======"

#cpu usage
echo "Current cpu usage"
top -bn1 | grep "Cpu(s)"

echo "======================="

#memory usage
echo "Current memory usage"
free -h

echo "======================"

#display top 10 memory consuming process
echo "Top 10 memory consumin processes"
ps aux --sort=-%mem | head -n 11

#ask for a pid

echo ""
read -p "Enter the PID of the process you want to terminate : " PID

#check wether PID

if ! ps -p "$PID" >/dev/null
then
	echo "process with PID $PID dose not exist."
	exit 1
fi

echo "==========================="

#prevent terminantion of critical processes

 PROCESS_NAME=$(ps -p "$PID" -o comm=)

if [ "$PID" -eq 1 ] || \
	[ "$PROCESS_NAME" = "systemd" ] || \
	[ "$PROCESS_NAME" = "init" ] || \
	[ "$PROCESS_NAME" = "kthreadd" ]
then
	echo "WARNING: This is a critical system process."
	echo "The process will Not be terminated."
	exit 1
fi

echo "================================="

#display selected process

echo "Selected process: "
ps -p "$PID" -o pid,user,%cpu,%mem,comm

echo "====================="

#ask confirmation

echo ""
read -p "Are you sure you want to terminate this process? (y/n): " CONFIRM


#terminate process only after confirmation
#--------------------------------

if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]

then 
	kill "$PID"
	echo "Process $PID has been terminated."

elif [ "$CONFIRM" = "n" ] || [ "$CONFIRM" = "N"]
then
	echo "Process termination cancelled."

else
	echo "Invalid! . Please enter y or n."
fi

echo " ==Done== "

