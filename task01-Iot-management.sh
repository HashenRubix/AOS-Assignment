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

