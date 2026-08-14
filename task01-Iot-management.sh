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


