
Explanation:

1. Variables:

OUTPUT_FILE: The file where the CPU and GPU usage data will be saved.

INTERVAL: Time interval (in seconds) between each data collection point.

SAMPLES: Number of samples to collect, calculated as 180 seconds / INTERVAL.

2. Header:

echo "Timestamp,Average_CPU_User,Average_CPU_System,Average_CPU_Idle,Average_GPU_Utilization" > $OUTPUT_FILE: Writes the CSV header to the file.

3. Accumulators:

Initialize accumulators (total_cpu_user, total_cpu_system, total_cpu_idle, total_gpu_utilization) to store the sum of each metric.

4.Data Collection Functions:

collect_cpu_usage: Uses mpstat to get CPU usage data and formats it with awk to extract user, system, and idle times.
collect_gpu_usage: Uses intel_gpu_top with jq to parse JSON output and calculate average GPU utilization.

5. Loop:

The for loop runs for the number of samples specified (36 in this case), collecting CPU and GPU usage data, and then sleeping for the specified interval (5 seconds) between samples.
Accumulates the CPU and GPU usage values during each iteration.

6. Average Calculation:

After the loop, calculates the average values for CPU and GPU usage.

7. Output:

Writes the average values to the CSV file along with the current timestamp.


How to:
1. $ chmod +x usage_monitor.sh
3. $ ./usage_monitor.sh
