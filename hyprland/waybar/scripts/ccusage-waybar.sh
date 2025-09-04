#!/bin/bash

# CC Usage Monitor for Waybar
# Displays daily and monthly usage from ccusage command

# Set timeout for commands
export TIMEOUT=10

# Function to get daily usage
get_daily_usage() {
    local today=$(date +%Y%m%d)
    local result=$(timeout $TIMEOUT bunx ccusage daily --since "$today" --until "$today" --json 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$result" ]; then
        # Parse JSON and extract daily cost
        daily=$(echo "$result" | jq -r '.daily[0].totalCost // 0' 2>/dev/null)
        if [ -z "$daily" ] || [ "$daily" = "null" ]; then
            daily="0"
        fi
        echo "$daily" | awk '{printf "%.2f", $1}'
    else
        echo "0.00"
    fi
}

# Function to get monthly total
get_monthly_usage() {
    # Remove ANSI escape codes and get the monthly total
    local result=$(timeout $TIMEOUT bunx ccusage monthly 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | grep -E 'Total.*\$' | tail -1)
    
    if [ -n "$result" ]; then
        # Extract the dollar amount
        monthly=$(echo "$result" | grep -oE '\$[0-9,]+\.?[0-9]*' | tr -d '$,' | head -1)
        if [ -z "$monthly" ]; then
            monthly="0"
        fi
        echo "$monthly" | awk '{printf "%.2f", $1}'
    else
        echo "0.00"
    fi
}

# Main execution - catch any errors
{
    daily_usage=$(get_daily_usage)
    monthly_usage=$(get_monthly_usage)
    
    # Format output for waybar
    # Waybar expects JSON output with text, tooltip, and class
    printf '{"text":"$%.2f","tooltip":"Today: $%.2f\\nMonth: $%.2f","class":"ccusage","alt":"ccusage"}\n' \
           "$daily_usage" "$daily_usage" "$monthly_usage"
} 2>/dev/null || {
    # Fallback if something goes wrong
    echo '{"text":"$0.00","tooltip":"Error loading data","class":"ccusage","alt":"ccusage"}'
}