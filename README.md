
# geolog.sh - SSH Login Attempts Monitor

## Description

`geolog.sh` is a bash script that analyzes failed SSH login attempts from system journal logs. It provides a summary of attempts by country and lists the top usernames and ports targeted. This script is useful for system administrators who want to monitor and secure their SSH services.

## Features

- Summarizes failed SSH login attempts by country
- Lists the top usernames targeted
- Lists the top ports targeted
- Calculates total login attempts, attempts per hour, and attempts per minute

## Prerequisites

- Linux system with `systemd` journal logs
- `geoiplookup` tool for IP-to-country resolution (install `geoip-bin` package)

## Installation

1. Clone the repository or download the script.
2. Make the script executable:
   ```bash
   chmod +x geolog.sh
   ```

## Usage

Run the script with sudo to ensure it has the necessary permissions to read the system journal logs:

```bash
sudo ./geolog.sh
```

The script will analyze the SSH login attempts since today by default. You can change the timeframe by modifying the `TIMEFRAME` variable in the script:

```bash
# Set the timeframe for log analysis
TIMEFRAME="24 hours ago"  # Example: Analyze logs from the past 24 hours
```

## Output

The script outputs the following information:

1. **SSH Login Attempts Summary**: A summary of attempts by country with percentages.
2. **Top Username Attempts**: A list of the top usernames targeted by failed login attempts.
3. **Top Port Attempts**: A list of the top ports targeted by failed login attempts.
4. **Total SSH Login Attempts**: The total number of failed login attempts.
5. **Attempts per Hour**: The average number of attempts per hour.
6. **Attempts per Minute**: The average number of attempts per minute.

## Example Output

```
SSH Login Attempts Summary:
---------------------------
Country                                  Percentage
Colombia                                       1.66%
South Korea                                    0.72%
Romania                                        0.28%
United States                                  2.32%
Unknown                                        0.72%
Chile                                          0.72%
India                                          0.55%
Russia                                         0.17%
Indonesia                                      1.66%
Germany                                        0.61%
Lithuania                                      0.28%
China                                         85.50%
Hong Kong                                      2.77%
Brazil                                         0.17%
Singapore                                      1.88%

Top Username Attempts:
----------------------
   1712 root
     12 ubuntu
      7 user
      7 admin
      5 ftpuser
      4 es
      3 test1
      3 sftp
      3 elasticsearch
      2 user2

Top Port Attempts:
------------------
      5 5814
      4 37650
      3 63902
      3 63517
      3 63195
      3 62620
      3 62355
      3 59858
      3 59160
      3 56449

Total SSH Login Attempts: 1807
Attempts per Hour: 993.16
Attempts per Minute: 16.5527
```

## Notes

- Ensure `geoiplookup` is installed on your system. You can install it using the following command:
  ```bash
  sudo apt-get install geoip-bin
  ```

- The script requires sudo privileges to access the system journal logs.

## License

This script is released under the MIT License.
