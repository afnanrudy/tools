#!/bin/bash

# File to store the CPU and GPU usage data
OUTPUT_FILE="usage_data.csv"

# Time interval in seconds between data collection
INTERVAL=5

# Number of samples to collect (3 minutes = 180 seconds, 180 / INTERVAL)
SAMPLES=36

# Write the header to the CSV file
echo "Timestamp,Average_CPU_User,Average_CPU_System,Average_CPU_Idle,Average_GPU_Utilization" > $OUTPUT_FILE

# Initialize accumulators for CPU and GPU usage
total_cpu_user=0
total_cpu_system=0
total_cpu_idle=0
total_gpu_utilization=0

# Function to collect CPU usage data using mpstat
collect_cpu_usage() {
    mpstat 1 1 | awk '/all/ {print $4, $6, $13}'
}

# Function to collect GPU usage data using intel_gpu_top
collect_gpu_usage() {
    intel_gpu_top -J -s 1 2>/dev/null | jq -r '.engines[].busy' | awk '{sum+=$1} END {print sum/NR}'
}

# Collect CPU and GPU usage data at specified intervals
for ((i=0; i<$SAMPLES; i++))
do
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    CPU_USAGE=$(collect_cpu_usage)
    GPU_USAGE=$(collect_gpu_usage)
    
    # Split the CPU usage data into individual variables
    CPU_USER=$(echo $CPU_USAGE | awk '{print $1}')
    CPU_SYSTEM=$(echo $CPU_USAGE | awk '{print $2}')
    CPU_IDLE=$(echo $CPU_USAGE | awk '{print $3}')
    
    # Accumulate the CPU and GPU usage values
    total_cpu_user=$(echo "$total_cpu_user + $CPU_USER" | bc)
    total_cpu_system=$(echo "$total_cpu_system + $CPU_SYSTEM" | bc)
    total_cpu_idle=$(echo "$total_cpu_idle + $CPU_IDLE" | bc)
    total_gpu_utilization=$(echo "$total_gpu_utilization + $GPU_USAGE" | bc)
    
    sleep $INTERVAL
done

# Calculate the averages
avg_cpu_user=$(echo "scale=2; $total_cpu_user / $SAMPLES" | bc)
avg_cpu_system=$(echo "scale=2; $total_cpu_system / $SAMPLES" | bc)
avg_cpu_idle=$(echo "scale=2; $total_cpu_idle / $SAMPLES" | bc)
avg_gpu_utilization=$(echo "scale=2; $total_gpu_utilization / $SAMPLES" | bc)

# Write the average values to the CSV file
echo "$(date +"%Y-%m-%d %H:%M:%S"),$avg_cpu_user,$avg_cpu_system,$avg_cpu_idle,$avg_gpu_utilization" >> $OUTPUT_FILE

echo "CPU and GPU usage data collection complete. Data saved in $OUTPUT_FILE"
