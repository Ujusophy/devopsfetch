#!/bin/bash

print_ports() {
    port_filter="$1"

    echo -e "**Fetching active ports and services...**"
    echo -e "$(printf "%-20s\t%-10s\t%-20s" "USER" "PORT" "SERVICE")"

    ss -tuln4p | awk -v port_filter="$port_filter" '
    BEGIN {
        FS = " "
        OFS = "\t"
    }
    /^tcp/ {
        # Extract user information
        if ($6 ~ /users:\(\(")"/) {
            split($6, a, ":")
            user = a[2]
            gsub(/[()]/, "", user)
        } else {
            user = "unknown"
        }

        # Extract port and filter
        port = gensub(/.*:(.*)/, "\\1", "g", $4)
        if (port == port_filter || port_filter == "") {
            # Print the output
            printf "%-20s\t%-10s\t%-20s\n", user, port, $6
        }
    }
    '
}

print_docker() {
    echo -e "Fetching Docker images and containers..."
    echo -e "TYPE\tID\t\t\t\tNAME"

    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}" | sed '1d' | while read -r line; do
        repo=$(echo "$line" | awk '{print $1}')
        tag=$(echo "$line" | awk '{print $2}')
        id=$(echo "$line" | awk '{print $3}')

        echo -e "$(printf "%-20s" "$repo")\t$(printf "%-10s" "$tag")\t$id"
    done

    docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}" | sed '1d' | while read -r line; do
        id=$(echo "$line" | awk '{print $1}')
        image=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | awk '{print $3}')

        echo -e "$(printf "%-20s" "$id")\t$(printf "%-20s" "$image")\t$name"
    done
}

print_nginx() {
    domain_filter="$1"

    echo -e "**Fetching Nginx domains, proxy destinations, and configuration files...**"
    echo -e "$(printf "%-20s\t%-50s\t%-30s" "DOMAIN" "PROXY TO" "CONFIG")"

    sudo nginx -T 2>/dev/null | awk -v filter="$domain_filter" '
    BEGIN {
      RS = "server {"
      FS = "\n"
      ORS = ""
    }

    {
      domain = ""
      proxy_to = ""
      config_file = ""

      # Loop through each line in the block
      for (i = 1; i <= NF; i++) {
        # Check for server_name directive
        if ($i ~ /server_name/) {
          domain = $i
          gsub(/server_name|;|\t/, "", domain)
          gsub(/^ +| +$/, "", domain)
        }

        # Check for proxy_pass directive
        if ($i ~ /proxy_pass/) {
          proxy_to = $i
          gsub(/proxy_pass|;|\t/, "", proxy_to)
          gsub(/^ +| +$/, "", proxy_to)
        }

        # Capture the config file from nginx configuration
        if ($i ~ /include/) {
          config_file = $i
          gsub(/include|;|\t/, "", config_file)
          gsub(/^ +| +$/, "", config_file)
        }
      }

      if (domain != "" && (filter == "" || domain ~ filter)) {
        printf "%-20s\t%-50s\t%-30s\n", domain, proxy_to, config_file
      }
    }
    '
}

print_users() {
    username_filter="$1"
    
    if [ -z "$username_filter" ]; then
        echo -e "Fetching users and last login times..."
        echo -e "$(printf "%-15s\t%s" "USER" "LAST LOGIN TIME")"
    
        last | awk '
        BEGIN {
            print "USER\tLAST LOGIN TIME"
        }
        {
            user=$1
            if (user !~ /^[0-9]/ && user != "reboot") {
                last_login_time=sprintf("%s-%s-%s %s:%s", $3, $5, $6, $4, $7)
                printf "%-15s %s\n", user, last_login_time
            }
        }
        '
    else
        echo -e "Fetching details for user: $username_filter..."
        echo -e "$(printf "%-15s\t%s" "USER" "DETAILS")"
    
        last | awk -v user_filter="$username_filter" '
        BEGIN {
            print "USER\tDETAILS"
        }
        {
            user=$1
            if (user == user_filter) {
                login_time=sprintf("%s-%s-%s %s:%s", $3, $5, $6, $4, $7)
                printf "%-15s %s\n", user, login_time
            }
        }
        '
        
        echo -e "\nFetching group memberships for user: $username_filter..."
        echo -e "$(printf "%-15s\t%s" "GROUP" "GID")"
    
        id -Gn "$username_filter" | tr ' ' '\n' | while read -r group; do
            gid=$(getent group "$group" | cut -d: -f3)
            printf "%-15s\t%s\n" "$group" "$gid"
        done
    fi
}

print_time() {
    if [ -z "$1" ]; then
        echo -e "Error: No date specified. Please provide a date or date range in the format 'YYYY-MM-DD' (e.g., '2024-07-18' or '2024-07-18 2024-07-22')."
        return 1
    fi

    echo -e "Fetching activities within the specified time range..."

    if [ -n "$2" ]; then
        start_date=$(date -d "$1" "+%Y-%m-%d" 2>/dev/null)
        end_date=$(date -d "$2" "+%Y-%m-%d" 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "Error: Invalid date format. Please provide dates in the format 'YYYY-MM-DD' (e.g., '2024-07-18 2024-07-22')."
            return 1
        fi
    else
        start_date=$(date -d "$1" "+%Y-%m-%d" 2>/dev/null)
        end_date=$start_date
        if [ $? -ne 0 ]; then
            echo -e "Error: Invalid date format. Please provide a date in the format 'YYYY-MM-DD' (e.g., '2024-07-18')."
            return 1
        fi
    fi

    echo -e "$(printf "%-15s\t%s" "USER" "ACTIVITY")"

    sudo journalctl --since "$start_date" --until "$end_date 23:59:59" | awk '
    {
        user=$3
        activity=$0
        if (user != "" && activity != "") {
            printf "%-15s %s\n", user, activity
        }
    }
    ' | column -t
}

print_help() {
    echo -e "Usage: $0 [options]"
    echo -e "Options:"
    echo -e "  -p, --port           List active ports, services, and users"
    echo -e "  -p <port_number>     Provide detailed information about a specific port"
    echo -e "  -d, --docker         List Docker images and containers"
    echo -e "  -n, --nginx <domain> List Nginx domains and ports"
    echo -e "  -u, --users <username> List users and their last login times, or details of a specific user"
    echo -e "  -t, --time           Display activities within a specified time range"
    echo -e "  -h, --help           Show this help message"
}

case "$1" in
    -p|--port)
        if [ -z "$2" ]; then
            print_ports
        else
            print_ports "$2"
        fi
        ;;
    -d|--docker)
        print_docker
        ;;
    -n|--nginx)
        print_nginx "$2"
        ;;
    -u|--users)
        print_users "$2"
        ;;
    -t|--time)
        if [ -z "$2" ]; then
            print_help
        else
            print_time "$2" "$3"
        fi
        ;;
    -h|--help)
        print_help
        ;;
    *)
        echo "Invalid option. Use -h or --help for usage information."
        ;;
esac
