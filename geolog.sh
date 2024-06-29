#!/bin/bash

# geolog.sh - SSH Login Attempts Monitor
# This script analyzes failed SSH login attempts and provides a summary of attempts by country,
# and also lists the top username and port attempts separately.

# Ensure script runs with sudo
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit
fi

# Check for necessary dependencies
if ! command -v geoiplookup &>/dev/null; then
  echo "geoiplookup could not be found. Please install geoip-bin."
  exit 1
fi

# Set the timeframe for log analysis
TIMEFRAME="today"  # Change this as needed, e.g., "today", "24 hours ago", "7 days ago", "2024-06-01"

# Extended country code to country name mapping
declare -A country_map=( 
  ["CN"]="China" 
  ["US"]="United States" 
  ["RU"]="Russia" 
  ["IN"]="India" 
  ["RO"]="Romania" 
  ["LT"]="Lithuania" 
  ["CL"]="Chile" 
  ["SG"]="Singapore" 
  ["HK"]="Hong Kong" 
  ["KR"]="South Korea" 
  ["ID"]="Indonesia" 
  ["CO"]="Colombia" 
  ["DE"]="Germany"
  ["BE"]="Belgium"
  ["MX"]="Mexico"
  ["IR"]="Iran"
  ["TR"]="Turkey"
  ["VE"]="Venezuela"
  ["EG"]="Egypt"
  ["PH"]="Philippines"
  ["HU"]="Hungary"
  ["CA"]="Canada"
  ["SK"]="Slovakia"
  ["PK"]="Pakistan"
  ["TH"]="Thailand"
  ["RS"]="Serbia"
  ["MY"]="Malaysia"
  ["BD"]="Bangladesh"
  ["UG"]="Uganda"
  ["SA"]="Saudi Arabia"
  ["LU"]="Luxembourg"
  ["MA"]="Morocco"
  ["AU"]="Australia"
  ["GR"]="Greece"
  ["UZ"]="Uzbekistan"
  ["TF"]="French Southern Territories"
  ["SY"]="Syria"
  ["NG"]="Nigeria"
  ["UA"]="Ukraine"
  ["ZA"]="South Africa"
  ["SE"]="Sweden"
  ["VN"]="Vietnam"
  ["BG"]="Bulgaria"
  ["NL"]="Netherlands"
  ["ES"]="Spain"
  ["AE"]="United Arab Emirates"
  ["GB"]="United Kingdom"
  ["KZ"]="Kazakhstan"
  ["FR"]="France"
  ["SC"]="Seychelles"
  ["IE"]="Ireland"
  ["BR"]="Brazil"
  ["KG"]="Kyrgyzstan"
  ["JP"]="Japan"
  ["PL"]="Poland"
  ["NO"]="Norway"
  ["AR"]="Argentina"
  ["ET"]="Ethiopia"
  ["TW"]="Taiwan"
  ["PE"]="Peru"
  ["Unknown"]="Unknown"
)

# Fetch failed SSH login attempts from logs
journalctl -u ssh --since "$TIMEFRAME" | grep 'Failed password' > failed_attempts.txt

# Check if the file was created and has content
if [ ! -s failed_attempts.txt ]; then
  echo "No failed SSH login attempts found in the specified timeframe ($TIMEFRAME)."
  exit 1
fi

# Analyze IPs and countries
awk '{print $(NF-3)}' failed_attempts.txt | sort | uniq -c | while read -r count ip; do
  country=$(geoiplookup "$ip" | awk -F ': ' '{print $2}' | awk -F ',' '{print $1}')
  if [[ -z "$country" || "$country" == "IP Address not found" ]]; then
    country="Unknown"
  fi
  echo "$count $country"
done > country_counts.txt

# Aggregate counts by country
awk '{a[$2]+=$1} END {for (i in a) print a[i], i}' country_counts.txt > aggregated_counts.txt

# Calculate total number of attempts
total_attempts=$(awk '{s+=$1} END {print s}' aggregated_counts.txt)

# Calculate attempts per hour and per minute
current_time=$(date +%s)
start_time=$(journalctl -u ssh --since "$TIMEFRAME" | grep 'Failed password' | head -1 | awk '{print $1" "$2" "$3}')
start_epoch=$(date -d "$start_time" +%s)
time_diff=$((current_time - start_epoch))
attempts_per_hour=$(awk -v total="$total_attempts" -v diff="$time_diff" 'BEGIN {print total / (diff / 3600)}')
attempts_per_minute=$(awk -v total="$total_attempts" -v diff="$time_diff" 'BEGIN {print total / (diff / 60)}')

# Display summary with headers
echo "SSH Login Attempts Summary:"
echo "---------------------------"
printf "%-40s %10s\n" "Country" "Percentage"

# Calculate percentages and replace country codes with full names
awk -v total="$total_attempts" '{country = $2; for (i = 3; i <= NF; i++) country = country " " $i; printf "%-40s %10.2f\n", country, ($1/total*100)}' aggregated_counts.txt | while read -r line; do
  code=$(echo "$line" | awk '{print $1}')
  percentage=$(echo "$line" | awk '{print $2}')
  country_name="${country_map[$code]}"
  if [[ -z "$country_name" ]]; then
    country_name="$code"
  fi
  printf "%-40s %10.2f%%\n" "$country_name" "$percentage"
done

# Extract and count username attempts
grep 'Failed password' failed_attempts.txt | awk '{print $(NF-5)}' | sort | uniq -c | sort -nr > username_attempts.txt

# Extract and count port attempts
grep 'Failed password' failed_attempts.txt | awk '{print $(NF-1)}' | sort | uniq -c | sort -nr > port_attempts.txt

# Display top username attempts
echo
echo "Top Username Attempts:"
echo "----------------------"
cat username_attempts.txt | head -n 10

# Display top port attempts
echo
echo "Top Port Attempts:"
echo "------------------"
cat port_attempts.txt | head -n 10

# Display total attempts, attempts per hour, and attempts per minute
echo
echo "Total SSH Login Attempts: $total_attempts"
echo "Attempts per Hour: $attempts_per_hour"
echo "Attempts per Minute: $attempts_per_minute"

# Clean up
rm country_counts.txt aggregated_counts.txt failed_attempts.txt username_attempts.txt port_attempts.txt
