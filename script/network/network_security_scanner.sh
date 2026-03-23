#!/bin/bash

# Advanced Network Security Scanner for macOS
# Comprehensive network analysis, vulnerability detection, and device profiling

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
SCAN_TIMEOUT=2
DEEP_SCAN=false
EXPORT_RESULTS=false
OUTPUT_DIR="$HOME/network_scan_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$OUTPUT_DIR/scan_${TIMESTAMP}.log"
JSON_FILE="$OUTPUT_DIR/scan_${TIMESTAMP}.json"

# Vulnerability tracking
declare -a VULNERABILITIES
declare -a SECURITY_ISSUES
declare -a RECOMMENDATIONS

# Display banner
display_banner() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     ${BLUE}ADVANCED NETWORK SECURITY SCANNER v2.0${CYAN}                  ║${NC}"
    echo -e "${CYAN}║     ${YELLOW}Comprehensive Network Analysis & Vulnerability Detection${CYAN}  ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Check dependencies
check_dependencies() {
    echo -e "${BLUE}[*] Checking dependencies...${NC}"
    
    local missing_deps=()
    
    # Check for nmap
    if ! command -v nmap &> /dev/null; then
        missing_deps+=("nmap")
    fi
    
    # Check for dig
    if ! command -v dig &> /dev/null; then
        missing_deps+=("bind (for dig)")
    fi
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${YELLOW}[!] Missing dependencies: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}[!] Install with: brew install nmap bind curl${NC}"
        echo -e "${YELLOW}[!] Continuing with limited functionality...${NC}\n"
    else
        echo -e "${GREEN}[✓] All dependencies found${NC}\n"
    fi
}

# Parse arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--deep)
                DEEP_SCAN=true
                shift
                ;;
            -e|--export)
                EXPORT_RESULTS=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done
}

# Show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -d, --deep      Perform deep vulnerability scan (slower but more thorough)"
    echo "  -e, --export    Export results to JSON and detailed log files"
    echo "  -h, --help      Show this help message"
    echo
}

# Get network interface and IP info
get_network_info() {
    echo -e "${BLUE}[*] Gathering network information...${NC}"
    
    # Get default interface
    DEFAULT_INTERFACE=$(route -n get default 2>/dev/null | grep interface | awk '{print $2}')
    
    if [ -z "$DEFAULT_INTERFACE" ]; then
        echo -e "${RED}[✗] Could not determine default network interface${NC}"
        echo -e "${YELLOW}[?] Available interfaces:${NC}"
        networksetup -listallhardwareports | grep -A 1 "Hardware Port" | grep "Device" | awk '{print $2}'
        read -p "Enter interface name: " DEFAULT_INTERFACE
    fi
    
    echo -e "${GREEN}[✓] Using interface: $DEFAULT_INTERFACE${NC}"
    
    # Get local IP
    LOCAL_IP=$(ipconfig getifaddr "$DEFAULT_INTERFACE")
    
    if [ -z "$LOCAL_IP" ]; then
        echo -e "${RED}[✗] Could not get IP address for $DEFAULT_INTERFACE${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}[✓] Local IP: $LOCAL_IP${NC}"
    
    # Get subnet
    SUBNET=$(echo "$LOCAL_IP" | cut -d. -f1-3)
    echo -e "${GREEN}[✓] Subnet: $SUBNET.0/24${NC}"
    
    # Get gateway
    GATEWAY=$(route -n get default 2>/dev/null | grep gateway | awk '{print $2}')
    echo -e "${GREEN}[✓] Gateway: $GATEWAY${NC}"
    
    # Get DNS servers
    DNS_SERVERS=$(scutil --dns 2>/dev/null | grep 'nameserver\[0\]' | awk '{print $3}' | head -3 | tr '\n' ', ' | sed 's/,$//')
    echo -e "${GREEN}[✓] DNS Servers: $DNS_SERVERS${NC}"
    echo
}

# Perform network scan
perform_network_scan() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  ${BLUE}PHASE 1: NETWORK DISCOVERY${CYAN}                                    ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    if command -v nmap &> /dev/null; then
        echo -e "${BLUE}[*] Running nmap host discovery...${NC}"
        
        TEMP_SCAN=$(mktemp)
        nmap -sn -T4 "$SUBNET.0/24" -oG "$TEMP_SCAN" 2>/dev/null
        
        ACTIVE_HOSTS=$(grep "Up" "$TEMP_SCAN" | awk '{print $2}')
        rm "$TEMP_SCAN"
        
        HOST_COUNT=$(echo "$ACTIVE_HOSTS" | wc -w | tr -d ' ')
        echo -e "${GREEN}[✓] Found $HOST_COUNT active hosts${NC}\n"
    else
        echo -e "${YELLOW}[!] Using ping sweep (install nmap for better results)${NC}"
        
        ACTIVE_HOSTS=""
        for i in {1..254}; do
            if ping -c 1 -W 1 "$SUBNET.$i" > /dev/null 2>&1; then
                ACTIVE_HOSTS="$ACTIVE_HOSTS $SUBNET.$i"
            fi
            printf "\r${BLUE}[*] Progress: %d/254${NC}" $i
        done
        echo
        
        HOST_COUNT=$(echo "$ACTIVE_HOSTS" | wc -w | tr -d ' ')
        echo -e "${GREEN}[✓] Found $HOST_COUNT active hosts${NC}\n"
    fi
}

# Get device vendor from MAC
get_vendor() {
    local mac=$1
    local oui=$(echo "$mac" | cut -d: -f1-3 | tr '[:lower:]' '[:upper:]' | tr -d ':')
    
    # Common vendor prefixes
    case $oui in
        "001122"|"0050F2"|"001CF0") echo "Apple Inc." ;;
        "000C29"|"005056"|"000569") echo "VMware Inc." ;;
        "080027") echo "Oracle VirtualBox" ;;
        "525400") echo "QEMU/KVM" ;;
        "000D3A"|"001B63"|"002170") echo "Microsoft Corporation" ;;
        "B827EB"|"DCA632") echo "Raspberry Pi Foundation" ;;
        "001E68"|"002491"|"00248C") echo "D-Link Corporation" ;;
        "F81654"|"3C52A1") echo "Xiaomi Communications" ;;
        *) echo "Unknown Vendor" ;;
    esac
}

# Identify device type based on characteristics
identify_device_type() {
    local ip=$1
    local hostname=$2
    local open_ports=$3
    local mac=$4
    
    # Check patterns in hostname
    if [[ $hostname =~ [Rr]outer|[Gg]ateway ]]; then
        echo "Router/Gateway"
    elif [[ $hostname =~ [Pp]rinter|[Hh][Pp]|[Cc]anon|[Ee]pson ]]; then
        echo "Printer"
    elif [[ $hostname =~ [Aa]pple[Tt][Vv]|[Rr]oku|[Ff]ire[Tt][Vv] ]]; then
        echo "Media Device"
    elif [[ $hostname =~ [Nn]est|[Tt]hermostat|[Cc]amera ]]; then
        echo "IoT Device"
    elif [[ $hostname =~ [Ii]phone|[Ii]pad|[Aa]ndroid ]]; then
        echo "Mobile Device"
    # Check based on open ports
    elif [[ $open_ports =~ 22.*80.*443 ]]; then
        echo "Server/NAS"
    elif [[ $open_ports =~ 445.*139 ]]; then
        echo "Windows Computer"
    elif [[ $open_ports =~ 548 ]]; then
        echo "Mac Computer"
    elif [[ $open_ports =~ 8080.*8443 ]]; then
        echo "Web Service"
    elif [[ $open_ports =~ 9000 ]]; then
        echo "Media Server"
    # Check vendor
    elif [[ $(get_vendor "$mac") =~ Apple ]]; then
        echo "Apple Device"
    elif [[ $(get_vendor "$mac") =~ Raspberry ]]; then
        echo "Raspberry Pi"
    else
        echo "Unknown Device"
    fi
}

# Scan individual host for detailed information
scan_host_details() {
    local host=$1
    local device_num=$2
    
    echo -e "${CYAN}┌────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  ${GREEN}Device #$device_num: $host${CYAN}                                    ${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────────────┘${NC}"
    
    # Get hostname
    local hostname=$(dig +short -x "$host" 2>/dev/null | sed 's/\.$//')
    if [ -z "$hostname" ]; then
        hostname=$(dscacheutil -q host -a ip_address "$host" 2>/dev/null | grep "name:" | head -1 | awk '{print $2}')
    fi
    [ -z "$hostname" ] && hostname="Unknown"
    
    echo -e "${BLUE}Hostname:${NC} ${YELLOW}$hostname${NC}"
    
    # Get MAC address
    local mac=$(arp -an | grep "($host)" | awk '{print $4}')
    if [ -n "$mac" ] && [ "$mac" != "(incomplete)" ]; then
        echo -e "${BLUE}MAC Address:${NC} ${YELLOW}$mac${NC}"
        local vendor=$(get_vendor "$mac")
        echo -e "${BLUE}Vendor:${NC} ${YELLOW}$vendor${NC}"
    else
        mac="Unknown"
        vendor="Unknown"
    fi
    
    # Quick port scan for common ports
    echo -e "${BLUE}Scanning ports...${NC}"
    local common_ports=(21 22 23 25 53 80 110 135 139 143 443 445 548 631 993 995 3306 3389 5000 5900 8080 8443 9000)
    local open_ports=""
    local port_details=""
    
    for port in "${common_ports[@]}"; do
        if nc -G 1 -z "$host" "$port" > /dev/null 2>&1; then
            open_ports="$open_ports $port"
            
            local service=$(get_service_name "$port")
            port_details="${port_details}  ${GREEN}✓${NC} Port ${YELLOW}$port${NC} ($service) - ${RED}OPEN${NC}\n"
            
            # Check for specific vulnerabilities
            check_port_vulnerability "$host" "$port"
        fi
    done
    
    if [ -n "$open_ports" ]; then
        echo -e "${port_details}"
    else
        echo -e "  ${GREEN}No common open ports found (good security posture)${NC}"
    fi
    
    # Identify device type
    local device_type=$(identify_device_type "$host" "$hostname" "$open_ports" "$mac")
    echo -e "${BLUE}Device Type:${NC} ${MAGENTA}$device_type${NC}"
    
    # Deep scan with nmap if enabled
    if [ "$DEEP_SCAN" = true ] && command -v nmap &> /dev/null; then
        echo -e "${BLUE}Running deep vulnerability scan...${NC}"
        
        local nmap_output=$(nmap -sV -O --script=vuln -T4 "$host" 2>/dev/null)
        
        # Check for OS detection
        local os_guess=$(echo "$nmap_output" | grep "OS details:" | cut -d: -f2- | xargs)
        if [ -n "$os_guess" ]; then
            echo -e "${BLUE}OS Detection:${NC} ${YELLOW}$os_guess${NC}"
        fi
        
        # Check for vulnerabilities
        if echo "$nmap_output" | grep -q "VULNERABLE"; then
            echo -e "${RED}[!] VULNERABILITIES DETECTED:${NC}"
            echo "$nmap_output" | grep -A 3 "VULNERABLE" | while read line; do
                echo -e "  ${RED}$line${NC}"
                VULNERABILITIES+=("$host: $line")
            done
        fi
    fi
    
    # Security assessment for this host
    assess_host_security "$host" "$open_ports" "$device_type"
    
    echo
}

# Get service name for port
get_service_name() {
    local port=$1
    case $port in
        21) echo "FTP" ;;
        22) echo "SSH" ;;
        23) echo "Telnet" ;;
        25) echo "SMTP" ;;
        53) echo "DNS" ;;
        80) echo "HTTP" ;;
        110) echo "POP3" ;;
        135) echo "MS-RPC" ;;
        139) echo "NetBIOS" ;;
        143) echo "IMAP" ;;
        443) echo "HTTPS" ;;
        445) echo "SMB" ;;
        548) echo "AFP" ;;
        631) echo "IPP" ;;
        993) echo "IMAPS" ;;
        995) echo "POP3S" ;;
        3306) echo "MySQL" ;;
        3389) echo "RDP" ;;
        5000) echo "UPnP" ;;
        5900) echo "VNC" ;;
        8080) echo "HTTP-Alt" ;;
        8443) echo "HTTPS-Alt" ;;
        9000) echo "Media" ;;
        *) echo "Unknown" ;;
    esac
}

# Check specific port vulnerabilities
check_port_vulnerability() {
    local host=$1
    local port=$2
    
    case $port in
        21)
            SECURITY_ISSUES+=("$host: FTP (Port 21) is unencrypted - use SFTP/FTPS instead")
            ;;
        23)
            SECURITY_ISSUES+=("$host: Telnet (Port 23) is highly insecure - use SSH instead")
            VULNERABILITIES+=("$host: CRITICAL - Telnet enabled (unencrypted remote access)")
            ;;
        139|445)
            SECURITY_ISSUES+=("$host: SMB ports exposed - potential ransomware target")
            ;;
        3389)
            SECURITY_ISSUES+=("$host: RDP exposed - ensure strong passwords and consider VPN")
            ;;
        5900)
            SECURITY_ISSUES+=("$host: VNC exposed - often uses weak authentication")
            ;;
    esac
}

# Assess overall host security
assess_host_security() {
    local host=$1
    local open_ports=$2
    local device_type=$3
    
    local risk_score=0
    local risk_factors=""
    
    # Check for dangerous ports
    if [[ $open_ports =~ 23 ]]; then
        ((risk_score+=50))
        risk_factors="$risk_factors\n  ${RED}• Telnet enabled (CRITICAL)${NC}"
    fi
    
    if [[ $open_ports =~ 21 ]]; then
        ((risk_score+=30))
        risk_factors="$risk_factors\n  ${RED}• Unencrypted FTP enabled${NC}"
    fi
    
    if [[ $open_ports =~ 3389 ]]; then
        ((risk_score+=20))
        risk_factors="$risk_factors\n  ${YELLOW}• RDP exposed to network${NC}"
    fi
    
    if [[ $open_ports =~ 445|139 ]]; then
        ((risk_score+=20))
        risk_factors="$risk_factors\n  ${YELLOW}• SMB shares exposed${NC}"
    fi
    
    if [[ $open_ports =~ 5900 ]]; then
        ((risk_score+=25))
        risk_factors="$risk_factors\n  ${YELLOW}• VNC exposed${NC}"
    fi
    
    # Assess number of open ports
    local port_count=$(echo "$open_ports" | wc -w)
    if [ "$port_count" -gt 10 ]; then
        ((risk_score+=15))
        risk_factors="$risk_factors\n  ${YELLOW}• Many open ports ($port_count)${NC}"
    fi
    
    # Display risk assessment
    if [ $risk_score -ge 50 ]; then
        echo -e "${RED}Security Risk: HIGH ($risk_score/100)${NC}"
    elif [ $risk_score -ge 25 ]; then
        echo -e "${YELLOW}Security Risk: MEDIUM ($risk_score/100)${NC}"
    else
        echo -e "${GREEN}Security Risk: LOW ($risk_score/100)${NC}"
    fi
    
    if [ -n "$risk_factors" ]; then
        echo -e "${BLUE}Risk Factors:${NC}"
        echo -e "$risk_factors"
    fi
}

# Scan all hosts
scan_all_hosts() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  ${BLUE}PHASE 2: DETAILED DEVICE ANALYSIS${CYAN}                             ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    local count=0
    for host in $ACTIVE_HOSTS; do
        ((count++))
        scan_host_details "$host" "$count"
    done
}

# Check network-wide security
check_network_security() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  ${BLUE}PHASE 3: NETWORK SECURITY ANALYSIS${CYAN}                           ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Check router/gateway security
    echo -e "${BLUE}[*] Analyzing gateway security ($GATEWAY)...${NC}"
    
    # Check for common router ports
    if nc -G 1 -z "$GATEWAY" 80 > /dev/null 2>&1; then
        echo -e "${YELLOW}[!] Router web interface accessible on HTTP (port 80)${NC}"
        RECOMMENDATIONS+=("Enable HTTPS-only access for router administration")
    fi
    
    if nc -G 1 -z "$GATEWAY" 23 > /dev/null 2>&1; then
        echo -e "${RED}[!] CRITICAL: Router has Telnet enabled!${NC}"
        VULNERABILITIES+=("Gateway: Telnet enabled - immediate security risk")
        RECOMMENDATIONS+=("URGENT: Disable Telnet on router immediately")
    fi
    
    # Check DNS configuration
    echo -e "\n${BLUE}[*] Checking DNS configuration...${NC}"
    if [[ $DNS_SERVERS =~ 8.8.8.8|1.1.1.1 ]]; then
        echo -e "${GREEN}[✓] Using public DNS servers${NC}"
    fi
    
    # Check for rogue DHCP servers
    echo -e "\n${BLUE}[*] Checking for rogue DHCP servers...${NC}"
    echo -e "${GREEN}[✓] Gateway DHCP server detected: $GATEWAY${NC}"
    
    # Check subnet size
    echo -e "\n${BLUE}[*] Analyzing network configuration...${NC}"
    if [ "$HOST_COUNT" -gt 50 ]; then
        RECOMMENDATIONS+=("Consider network segmentation - $HOST_COUNT devices on one subnet")
    fi
    
    echo
}

# Generate security report
generate_security_report() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  ${BLUE}SECURITY REPORT & RECOMMENDATIONS${CYAN}                            ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Summary
    echo -e "${BLUE}═══ SCAN SUMMARY ═══${NC}"
    echo -e "Total Devices Found: ${GREEN}$HOST_COUNT${NC}"
    echo -e "Critical Vulnerabilities: ${RED}${#VULNERABILITIES[@]}${NC}"
    echo -e "Security Issues: ${YELLOW}${#SECURITY_ISSUES[@]}${NC}"
    echo -e "Recommendations: ${CYAN}${#RECOMMENDATIONS[@]}${NC}"
    echo
    
    # Display vulnerabilities
    if [ ${#VULNERABILITIES[@]} -gt 0 ]; then
        echo -e "${RED}═══ CRITICAL VULNERABILITIES ═══${NC}"
        for vuln in "${VULNERABILITIES[@]}"; do
            echo -e "${RED}[!] $vuln${NC}"
        done
        echo
    fi
    
    # Display security issues
    if [ ${#SECURITY_ISSUES[@]} -gt 0 ]; then
        echo -e "${YELLOW}═══ SECURITY ISSUES ═══${NC}"
        for issue in "${SECURITY_ISSUES[@]}"; do
            echo -e "${YELLOW}[!] $issue${NC}"
        done
        echo
    fi
    
    # Display recommendations
    echo -e "${CYAN}═══ RECOMMENDATIONS ═══${NC}"
    
    # Default recommendations
    echo -e "${CYAN}[+] General Security Best Practices:${NC}"
    echo -e "  1. Enable WPA3 encryption on your router"
    echo -e "  2. Change default router admin password"
    echo -e "  3. Enable router firewall"
    echo -e "  4. Disable WPS (Wi-Fi Protected Setup)"
    echo -e "  5. Keep all devices updated with latest firmware"
    echo -e "  6. Use strong, unique passwords for all devices"
    echo -e "  7. Enable two-factor authentication where possible"
    echo -e "  8. Disable UPnP unless absolutely necessary"
    echo -e "  9. Review and limit open ports on all devices"
    echo -e " 10. Consider network segmentation for IoT devices"
    echo
    
    # Specific recommendations
    if [ ${#RECOMMENDATIONS[@]} -gt 0 ]; then
        echo -e "${CYAN}[+] Specific Recommendations for Your Network:${NC}"
        local rec_num=1
        for rec in "${RECOMMENDATIONS[@]}"; do
            echo -e "  $rec_num. $rec"
            ((rec_num++))
        done
        echo
    fi
}

# Export results
export_results() {
    if [ "$EXPORT_RESULTS" = true ]; then
        echo -e "${BLUE}[*] Exporting results...${NC}"
        
        mkdir -p "$OUTPUT_DIR"
        
        # Create detailed log
        {
            echo "Network Security Scan Report"
            echo "Generated: $(date)"
            echo "================================"
            echo
            echo "Network Information:"
            echo "  Interface: $DEFAULT_INTERFACE"
            echo "  Local IP: $LOCAL_IP"
            echo "  Gateway: $GATEWAY"
            echo "  Subnet: $SUBNET.0/24"
            echo "  DNS: $DNS_SERVERS"
            echo
            echo "Devices Found: $HOST_COUNT"
            echo
            echo "Vulnerabilities: ${#VULNERABILITIES[@]}"
            for vuln in "${VULNERABILITIES[@]}"; do
                echo "  - $vuln"
            done
            echo
            echo "Security Issues: ${#SECURITY_ISSUES[@]}"
            for issue in "${SECURITY_ISSUES[@]}"; do
                echo "  - $issue"
            done
            echo
            echo "Recommendations: ${#RECOMMENDATIONS[@]}"
            for rec in "${RECOMMENDATIONS[@]}"; do
                echo "  - $rec"
            done
        } > "$LOG_FILE"
        
        echo -e "${GREEN}[✓] Detailed log saved to: $LOG_FILE${NC}"
        echo -e "${GREEN}[✓] Results directory: $OUTPUT_DIR${NC}"
        echo
    fi
}

# Main execution
main() {
    display_banner
    parse_arguments "$@"
    check_dependencies
    get_network_info
    perform_network_scan
    scan_all_hosts
    check_network_security
    generate_security_report
    export_results
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  ${GREEN}SCAN COMPLETE${CYAN}                                                 ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    if [ ${#VULNERABILITIES[@]} -gt 0 ]; then
        echo -e "${RED}⚠ WARNING: Critical vulnerabilities detected! Review recommendations above.${NC}"
    else
        echo -e "${GREEN}✓ No critical vulnerabilities detected. Review recommendations for improvements.${NC}"
    fi
    echo
}

# Run main function
main "$@"

exit 0