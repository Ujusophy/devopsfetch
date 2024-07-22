#!/bin/bash

print_help() {
    echo "Usage: ./devopsfetch.sh [options]"
    echo "Options:"
    echo "  -p, --ports          List active ports and services"
    echo "  -d, --docker         List Docker images and containers"
    echo "  -n, --nginx          List Nginx domains and ports"
    echo "  -u, --users          List users and their last login times"
    echo "  -t, --time           Display activities within a specified time range"
    echo "  -h, --help           Show this help message"
}

print_ports() {
    echo -e "Fetching active ports and services..."
    netstat -tuln | awk 'NR>2 {print $1 "\t" $4 "\t" $5 "\t" $6 "\t" $7}' | column -t -s $'\t'
}

print_docker() {
    echo -e "Fetching Docker images and containers..."
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}" | column -t
    echo
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | column -t
}

print_nginx() {
    echo -e "Fetching Nginx domains and ports..."
    nginx -T | grep 'server_name' | awk '{print "Domain\tPort"; print $2 "\t" "80"}' | column -t
}

print_users() {
    echo -e "Fetching users and last login times..."
    awk -F: '{print $1 "\t" $5}' /etc/passwd | column -t
}

print_time() {
    echo -e "Time range feature not implemented yet."
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--ports)
            print_ports
            shift
            ;;
        -d|--docker)
            print_docker
            shift
            ;;
        -n|--nginx)
            print_nginx
            shift
            ;;
        -u|--users)
            print_users
            shift
            ;;
        -t|--time)
            if [[ $# -lt 3 ]]; then
                echo "Error: Missing parameters for time range."
                print_help
                exit 1
            fi
            # For now, just a placeholder for time range functionality
            print_time
            shift 3
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_help
            exit 1
            ;;
    esac
done
