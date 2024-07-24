#!/bin/bash

# Function to display all active ports and services
display_ports() {
    printf "%-15s | %-15s | %-15s\n" "User" "Port" "Service"
    printf "%-15s | %-15s | %-15s\n" "--------------" "--------------" "--------------"
    
    netstat -tuln | awk 'NR>2 {print $7, $4, $6}' | while IFS=" " read -r user port service; do
        printf "%-15s | %-15s | %-15s\n" "$user" "$port" "$service"
    done
}

# Function to provide detailed information about a specific port
display_port_info() {
    local port=$1
    printf "%-15s | %-15s | %-15s\n" "User" "Port" "Service"
    printf "%-15s | %-15s | %-15s\n" "--------------" "--------------" "--------------"
    
    netstat -tuln | awk -v port="$port" '$4 ~ ":"port {print $7, $4, $6}' | while IFS=" " read -r user port service; do
        printf "%-15s | %-15s | %-15s\n" "$user" "$port" "$service"
    done
}

# Function to display all server domains, proxies, and their configuration files
display_nginx() {
    printf "%-40s | %-40s | %-40s\n" "Domain" "Proxy" "Configuration File"
    printf "%-40s | %-40s | %-40s\n" "----------------------------------------" "----------------------------------------" "----------------------------------------"
    
    grep -r -E 'server_name|proxy_pass' /etc/nginx/sites-available/ | while IFS=":" read -r file line; do
        if echo "$line" | grep -q "server_name"; then
            domain=$(echo "$line" | awk '{print $2}' | sed 's/;$//')
        elif echo "$line" | grep -q "proxy_pass"; then
            proxy=$(echo "$line" | awk '{print $2}' | sed 's/;$//')
            printf "%-40s | %-40s | %-40s\n" "$domain" "$proxy" "$file"
        fi
    done
}

# Function to display detailed configuration information for a specific domain
display_nginx_info() {
    local domain=$1
    printf "%-40s | %-40s | %-40s\n" "Domain" "Port" "Configuration File"
    printf "%-40s | %-40s | %-40s\n" "----------------------------------------" "----------------------------------------" "----------------------------------------"
    
    grep -r -E "server_name $domain" /etc/nginx/sites-available/ | while IFS=":" read -r file line; do
        port=$(grep -r -E "listen" "$file" | awk '{print $2}' | sed 's/;$//')
        printf "%-40s | %-40s | %-40s\n" "$domain" "$port" "$file"
    done
}

# Function to list all users and their last login times
list_users() {
    printf "%-20s | %-20s\n" "Username" "Last Login"
    printf "%-20s | %-20s\n" "--------------------" "--------------------"
    while IFS=: read -r username _; do
        last_login=$(lastlog -u "$username" | awk 'NR==2 {print $4, $5, $6, $7}')
        printf "%-20s | %-20s\n" "$username" "$last_login"
    done < /etc/passwd
}

# Function to display detailed information about a specific user
user_info() {
    local username=$1
    printf "%-20s | %-20s\n" "Username" "Last Login"
    printf "%-20s | %-20s\n" "--------------------" "--------------------"
    last_login=$(lastlog -u "$username" | awk 'NR==2 {print $4, $5, $6, $7}')
    if [[ -n $last_login ]]; then
        printf "%-20s | %-20s\n" "$username" "$last_login"
    else
        printf "%-20s | %-20s\n" "$username" "No login record"
    fi
}

# Function to list all Docker images and containers
list_docker() {
    echo "Docker Images:"
    printf "%-30s | %-30s | %-30s\n" "Image ID" "Repository" "Tag"
    printf "%-30s | %-30s | %-30s\n" "------------------------------" "------------------------------" "------------------------------"
    docker images --format "{{.ID}} | {{.Repository}} | {{.Tag}}" | while IFS=" | " read -r id repo tag; do
        printf "%-30s | %-30s | %-30s\n" "$id" "$repo" "$tag"
    done

    echo -e "\nDocker Containers:"
    printf "%-30s | %-30s | %-30s | %-30s\n" "Container ID" "Image" "Status" "Names"
    printf "%-30s | %-30s | %-30s | %-30s\n" "------------------------------" "------------------------------" "------------------------------" "------------------------------"
    docker ps -a --format "{{.ID}} | {{.Image}} | {{.Status}} | {{.Names}}" | while IFS=" | " read -r id image status names; do
        printf "%-30s | %-30s | %-30s | %-30s\n" "$id" "$image" "$status" "$names"
    done
}

# Function to display detailed information about a specific container
container_info() {
    local container_id=$1
    printf "%-30s | %-30s\n" "Container ID" "Status"
    printf "%-30s | %-30s\n" "------------------------------" "------------------------------"
    container_info=$(docker inspect --format '{{.Id}} | {{.State.Status}}' "$container_id")
    if [[ -n $container_info ]]; then
        printf "%-30s | %-30s\n" $(echo "$container_info" | tr '|' ' ')
    else
        printf "%-30s | %-30s\n" "$container_id" "No such container"
    fi
}

# Function to display activities within a specified date
display_time_range() {
    local date=$1
    printf "%-30s | %-30s | %-30s\n" "Timestamp" "Message" "Source"
    printf "%-30s | %-30s | %-30s\n" "------------------------------" "------------------------------" "------------------------------"

    # Assuming we're using system logs for this example
    journalctl --since "$date 00:00:00" --until "$date 23:59:59" --no-pager | while IFS=" " read -r timestamp _ _ _ source message; do
        printf "%-30s | %-30s | %-30s\n" "$timestamp" "$message" "$source"
    done
}

print_help() {
    echo -e "Usage: $0 [options]"
    echo -e "Options:"
    echo -e "  -p, --port           List active ports, services, and users"
    echo -e "  -d, --docker         List Docker images and containers"
    echo -e "  -n, --nginx <domain> List Nginx domains and ports"
    echo -e "  -u, --users <username> List users and their last login times, or details of a specific user"
    echo -e "  -t, --time           Display activities within a specified time range"
    echo -e "  -h, --help           Show this help message"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_help
            exit 0
            ;;
        -p|--port)
            if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
                display_port_info "$2"
                shift
            else
                display_ports
            fi
            ;;
        -n|--nginx)
            if [[ -n $2 && ! $2 =~ ^- ]]; then
                display_nginx_info "$2"
                shift
            else
                display_nginx
            fi
            ;;
        -u|--users)
            if [[ -n $2 && $2 =~ ^[a-zA-Z0-9._-]+$ ]]; then
                user_info "$2"
                shift
            else
                list_users
            fi
            ;;
        -d|--docker)
            if [[ -n $2 && $2 =~ ^[a-zA-Z0-9._-]+$ ]]; then
                container_info "$2"
                shift
            else
                list_docker
            fi
            ;;
        -t|--time)
            if [[ -n $2 && $2 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                display_time_range "$2"
                shift
            else
                echo "Invalid date format. Please use YYYY-MM-DD."
                exit 1
            fi
            ;;
        *)
            echo "Invalid option: $1"
            echo "Usage: $0 [-n|--nginx [domain]] [-p|--port [port_number]] [-u|--users [username]] [-d|--docker [container_id]] [-t|--time YYYY-MM-DD]"
            exit 1
            ;;
    esac
    shift
done

# If no arguments provided, show usage
if [[ "$#" -eq 0 ]]; then
    echo "Usage: $0 [-n|--nginx [domain]] [-p|--port [port_number]] [-u|--users [username]] [-d|--docker [container_id]] [-t|--time YYYY-MM-DD]"
fi
