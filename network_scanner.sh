#!/bin/bash

# Network Device Scanner for macOS
# This script scans your local network for active devices and gathers basic information about them

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Display header
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   macOS Network Device Scanner Tool     ${NC}"
echo -e "${BLUE}=========================================${NC}"
echo

# Check if script is running with root privileges (needed for some commands)
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Warning: Some features may require root privileges.${NC}"
    echo -e "${YELLOW}Consider running with sudo for full functionality.${NC}"
    echo
fi

# Determine local network information
echo -e "${GREEN}Gathering network information...${NC}"

# Get list of active network interfaces (macOS specific)
echo "Available network interfaces:"
ACTIVE_INTERFACES=$(networksetup -listallhardwareports | grep -A 1 "Hardware Port" | grep "Device" | awk '{print $2}')

# Display available interfaces
for iface in $ACTIVE_INTERFACES; do
    echo "  - $iface"
done

# Ask user to select interface or try to determine primary interface
if [ -z "$1" ]; then
    # Try to find the primary interface on macOS
    DEFAULT_INTERFACE=$(route -n get default 2>/dev/null | grep interface | awk '{print $2}')
    
    if [ -z "$DEFAULT_INTERFACE" ]; then
        # If can't determine automatically, ask user
        echo -e "\nPlease select your network interface:"
        read -p "Enter interface name: " DEFAULT_INTERFACE
        if [ -z "$DEFAULT_INTERFACE" ]; then
            echo -e "${RED}No interface specified. Exiting.${NC}"
            exit 1
        fi
    fi
else
    DEFAULT_INTERFACE=$1
fi

echo -e "\nUsing interface: ${GREEN}$DEFAULT_INTERFACE${NC}"

# Get local IP address (macOS specific)
LOCAL_IP=$(ipconfig getifaddr "$DEFAULT_INTERFACE")

if [ -z "$LOCAL_IP" ]; then
    echo -e "${RED}Error: Could not determine local IP address for $DEFAULT_INTERFACE.${NC}"
    echo -e "${RED}Please verify this is a valid, connected interface.${NC}"
    exit 1
fi

echo -e "Local IP address: ${GREEN}$LOCAL_IP${NC}"

# Get subnet information
SUBNET=$(echo "$LOCAL_IP" | cut -d. -f1-3)
echo -e "Network subnet: ${GREEN}$SUBNET.0/24${NC}"
echo

# Scanning Function
scan_network() {
    echo -e "${BLUE}Starting network scan...${NC}"
    
    # Create a temporary file for scan results
    TEMP_FILE=$(mktemp)
    
    # Check if nmap is installed
    if command -v nmap &> /dev/null; then
        echo "Using nmap for network scanning..."
        echo -e "${YELLOW}This might take a minute or two...${NC}"
        
        # Run nmap scan
        nmap -sn "$SUBNET.0/24" -oG "$TEMP_FILE" > /dev/null 2>&1
        
        # Parse nmap results
        HOSTS=$(grep "Up" "$TEMP_FILE" | cut -d' ' -f2)
        
        # Remove temporary file
        rm "$TEMP_FILE"
    else
        echo "Nmap not found, using ping sweep instead..."
        echo -e "${YELLOW}This might take several minutes...${NC}"
        echo -e "${YELLOW}You can install nmap with: brew install nmap${NC}"
        
        # Ping sweep (slower but more compatible)
        HOSTS=""
        for i in {1..254}; do
            if ping -c 1 -W 1 "$SUBNET.$i" > /dev/null 2>&1; then
                HOSTS="$HOSTS $SUBNET.$i"
            fi
            # Show progress every 25 IPs
            if [ $((i % 25)) -eq 0 ]; then
                echo -ne "Progress: $i/254 IPs checked\r"
            fi
        done
        echo
    fi
    
    # Output results
    echo -e "${GREEN}Scan complete!${NC}"
    echo
    
    if [ -z "$HOSTS" ]; then
        echo -e "${RED}No devices found. Try running the script as root for better results.${NC}"
        exit 1
    fi
    
    process_results "$HOSTS"
}

# Process and display results
process_results() {
    local hosts="$1"
    local count=0
    
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}        Device Information              ${NC}"
    echo -e "${BLUE}=========================================${NC}"
    
    for host in $hosts; do
        count=$((count + 1))
        echo -e "\n${GREEN}Device #$count: $host${NC}"
        
        # Try to get hostname (macOS specific)
        hostname=$(dig +short -x "$host" 2>/dev/null | sed 's/\.$//')
        if [ -z "$hostname" ]; then
            hostname=$(dscacheutil -q host -a ip_address "$host" 2>/dev/null | grep "name:" | head -1 | awk '{print $2}')
        fi
        
        if [ -n "$hostname" ] && [ "$hostname" != "$host" ]; then
            echo -e "Hostname: ${YELLOW}$hostname${NC}"
        else
            echo -e "Hostname: ${YELLOW}Unknown${NC}"
        fi
        
        # Get MAC address using arp on macOS
        MAC=$(arp -an | grep "$host " | awk '{print $4}')
        if [ -n "$MAC" ] && [ "$MAC" != "(incomplete)" ]; then
            echo -e "MAC Address: ${YELLOW}$MAC${NC}"
            
            # MacOS doesn't have manufacturer database built-in
            # We could add an online lookup here, but keeping it simple
            echo -e "Manufacturer: ${YELLOW}Use 'system_profiler SPNetworkDataType' for more details${NC}"
        fi
        
        # Check common open ports
        echo "Checking common ports:"
        COMMON_PORTS=(22 80 443 445 3389 8080)
        
        for port in "${COMMON_PORTS[@]}"; do
            if nc -G 1 -z "$host" "$port" > /dev/null 2>&1; then
                echo -e "  ${YELLOW}Port $port: open${NC}"
                
                # Additional info for web ports
                if [ "$port" -eq 80 ] || [ "$port" -eq 443 ] || [ "$port" -eq 8080 ]; then
                    protocol="http"
                    [ "$port" -eq 443 ] && protocol="https"
                    
                    SERVER=$(curl -m 2 -s -I "$protocol://$host:$port" 2>/dev/null | grep -i "Server:" | cut -d: -f2- | sed 's/^[ \t]*//')
                    if [ -n "$SERVER" ]; then
                        echo -e "    Web Server: ${YELLOW}$SERVER${NC}"
                    fi
                fi
            fi
        done
        
        # Check for more info with nmap if available
        if command -v nmap &> /dev/null; then
            echo -e "\nDetailed service scan with nmap:"
            nmap -F -T4 "$host" 2>/dev/null | grep "open" | head -5 | 
            while read line; do
                echo -e "  ${YELLOW}$line${NC}"
            done
        fi
        
        echo -e "${BLUE}-----------------------------------------${NC}"
    done
    
    echo -e "\n${GREEN}Found $count devices on the network.${NC}"
}

# Start the scan
scan_network

echo -e "\n${BLUE}=========================================${NC}"
echo -e "${GREEN}Scan completed successfully!${NC}"
echo -e "${BLUE}=========================================${NC}"

exit 0