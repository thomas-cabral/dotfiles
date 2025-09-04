#!/bin/bash

# Check if nvidia-smi is available
if command -v nvidia-smi &> /dev/null; then
    # NVIDIA GPU
    gpu_usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n1)
    gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n1)
    gpu_mem=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | head -n1)
    mem_used=$(echo $gpu_mem | cut -d',' -f1 | xargs)
    mem_total=$(echo $gpu_mem | cut -d',' -f2 | xargs)
    mem_percent=$((mem_used * 100 / mem_total))
    
    echo "{\"text\": \"GPU ${gpu_usage}%\", \"tooltip\": \"GPU Usage: ${gpu_usage}%\\nTemperature: ${gpu_temp}°C\\nMemory: ${mem_used}MB / ${mem_total}MB (${mem_percent}%)\"}"
    
# Check for AMD GPU
elif [ -f /sys/class/drm/card0/device/gpu_busy_percent ]; then
    # AMD GPU (requires amdgpu driver)
    gpu_usage=$(cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null || echo "0")
    
    # Try to get temperature
    if [ -f /sys/class/drm/card0/device/hwmon/hwmon*/temp1_input ]; then
        gpu_temp=$(($(cat /sys/class/drm/card0/device/hwmon/hwmon*/temp1_input) / 1000))
    else
        gpu_temp="N/A"
    fi
    
    # Try to get memory usage
    if [ -f /sys/class/drm/card0/device/mem_info_vram_used ] && [ -f /sys/class/drm/card0/device/mem_info_vram_total ]; then
        mem_used=$(($(cat /sys/class/drm/card0/device/mem_info_vram_used) / 1048576))
        mem_total=$(($(cat /sys/class/drm/card0/device/mem_info_vram_total) / 1048576))
        mem_percent=$((mem_used * 100 / mem_total))
        echo "{\"text\": \"GPU ${gpu_usage}%\", \"tooltip\": \"GPU Usage: ${gpu_usage}%\\nTemperature: ${gpu_temp}°C\\nMemory: ${mem_used}MB / ${mem_total}MB (${mem_percent}%)\"}"
    else
        echo "{\"text\": \"GPU ${gpu_usage}%\", \"tooltip\": \"GPU Usage: ${gpu_usage}%\\nTemperature: ${gpu_temp}°C\"}"
    fi
    
# Intel GPU fallback
elif [ -f /sys/class/drm/card0/gt_cur_freq_mhz ]; then
    # Intel integrated GPU
    cur_freq=$(cat /sys/class/drm/card0/gt_cur_freq_mhz 2>/dev/null || echo "0")
    max_freq=$(cat /sys/class/drm/card0/gt_max_freq_mhz 2>/dev/null || echo "1000")
    gpu_usage=$((cur_freq * 100 / max_freq))
    
    echo "{\"text\": \"iGPU ${gpu_usage}%\", \"tooltip\": \"Intel GPU\\nFrequency: ${cur_freq}MHz / ${max_freq}MHz\"}"
else
    echo "{\"text\": \"GPU N/A\", \"tooltip\": \"GPU monitoring not available\"}"
fi