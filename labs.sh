#!/bin/bash

print_usage () {
    echo
    echo 'Usage:    labs.sh COMMAND'
    echo
    echo 'Control a class of hacklabs'
    echo
    echo 'Commands:'
    echo '    create              Setup hacklabs'
    echo '    up                  Create and start hacklabs'
    echo '    down                Stop and remove hacklabs'
    echo
}

lab_path=$(dirname $0)

if [ $# != 1 ]; then
    print_usage
elif [ $1 == "create" ] ; then
    read -p "How many hacklabs do you want to create?: " folder_count
    IFS=$'\r\n' GLOBIGNORE='*' command eval 'passwords=($(cat passwords.txt))'
    
    if [ ${#passwords[@]} -lt $folder_count ]; then
        echo "Not enough entries in passwords.txt. Found ${#passwords[@]}."
        exit 1
    fi
    
    for i in $(seq -f "%02g" 0 $((folder_count-1))); do
        if [ -d "$lab_path/hacklab$i" ]; then
            rm -rf "$lab_path/hacklab$i"
        fi
        
        mkdir $lab_path/hacklab$i
        cp $lab_path/docker-template.yml "$lab_path/hacklab$i/docker-compose.yml"
        
        sed -i "s/container_name: hacklabXX_/container_name: hacklab${i}_/g" "$lab_path/hacklab$i/docker-compose.yml"
        sed -i "s/: 172.0.X./: 172.0.$(echo "$i" | sed 's/^0//')./g" "$lab_path/hacklab$i/docker-compose.yml"
        sed -i "s/PASS: myPass/PASS: ${passwords[$(echo "$i" | sed 's/^0//')]}/g" "$lab_path/hacklab$i/docker-compose.yml"
    done
elif [ $1 == "up" ] ; then
    folder_count=$(find "$lab_path" -maxdepth 1 -type d -name "hacklab??" | wc -l)
    if [[ $folder_count -eq 0 ]]; then
        echo "No hacklab folders found. Run 'labs.sh create' first."
        exit 1
    fi
    
    for i in $(seq -f "%02g" 0 $((folder_count-1))); do
        docker compose -f $lab_path/hacklab$i/docker-compose.yml up -d
    done
    #docker compose -f $lab_path/edge/docker-compose.yml up -d
    echo
    echo 'All wrapped up here, sir. Will there be anything else?'
elif [ $1 == "down" ]; then
    for i in {00..00}; do
        docker compose -f $lab_path/hacklab$i/docker-compose.yml down
    done
    #docker compose -f $lab_path/edge/docker-compose.yml down
    echo
    echo 'The Clean Slate Protocol, sir?'
else
    print_usage
fi

