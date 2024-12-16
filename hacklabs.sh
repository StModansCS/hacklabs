#!/bin/bash

print_usage () {
    echo
    echo "Usage:    labs.sh COMMAND"
    echo
    echo "Classroom hacklabs"
    echo
    echo "Commands:"
    echo "    install             Install docker and hacklab files"
    echo "    create              Setup hacklabs"
    echo "    up                  Start hacklabs"
    echo "    down                Stop hacklabs"
    echo
}

# get path of parent folder
lab_path=$(dirname $0)

if [ $# != 1 ]; then
    print_usage
elif [ $1 == "install" ] ; then
    apt-get update
    
    # add Docker"s official GPG key:
    apt-get install ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    # add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "${VERSION_CODENAME}") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update

    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
elif [ $1 == "create" ] ; then
    read -p "How many hacklabs do you want to create?: " lab_count

    # get passwords
    IFS=$"\r\n" GLOBIGNORE="*" command eval "passwords=($(cat ${lab_path}/passwords.txt))"
    
    # check there are enough passwords
    if [ ${#passwords[@]} -lt $lab_count ]; then
        echo "Not enough entries in passwords.txt. Found ${#passwords[@]}"
        exit 1
    fi

    # remove old hacklabs
    sed -i "'/hacklab[0-9][0-9]_net:/d; /external: true/d'" "${lab_path}/compose-files/edge/compose.yaml"
    
    # create hacklabs
    for i in $(seq -f "%02g" 0 $((lab_count - 1))); do
        # create docker compose files
        mkdir "${lab_path}/compose-files/hacklab${i}"
        cp "${lab_path}/compose-files/compose-template.yaml" "${lab_path}/compose-files/hacklab${i}/compose.yaml"
        
        # edit compose files
        sed -i "s/hacklabXXXX_/hacklab${i}_/g" "${lab_path}/compose-files/hacklab${i}/compose.yaml"
        sed -i "s/.XXXX./.$(echo "${i}" | sed "s/^0//")./g" "${lab_path}/compose-files/hacklab${i}/compose.yaml"
        sed -i "s/PASS: myPass/PASS: ${passwords[$(echo "${i}" | sed "s/^0//")]}/g" "${lab_path}/compose-files/hacklab${i}/compose.yaml"
    done

    # remove old hacklab networks from edge
    sed -i "/networks:/q" "${lab_path}/compose-files/edge/compose.yaml"

    # add hacklab networks to edge
    for i in $(seq -f "%02g" 0 $((lab_count - 1))); do
        # get network name from compose file
        sed -n "/^networks:/,/^[^ ]/ { /name:/s/.*name: \(.*\)/      - \1/p }" "${lab_path}/compose-files/hacklab${i}/compose.yaml" >> "${lab_path}/compose-files/edge/compose.yaml"
    done

    # add hacklab network definitions to edge
    echo >> "${lab_path}/compose-files/edge/compose.yaml"
    echo "networks:" >> "${lab_path}/compose-files/edge/compose.yaml"
    echo "  # see ../hacklabXX/compose.yaml" >> "${lab_path}/compose-files/edge/compose.yaml"
    for i in $(seq -f "%02g" 0 $((lab_count - 1))); do
        sed -n "/^networks:/,/^[^ ]/ { /name:/s/.*name: \(.*\)/  \1:/p }" "${lab_path}/compose-files/hacklab${i}/compose.yaml" >> "${lab_path}/compose-files/edge/compose.yaml"
        echo "    external: true" >> "${lab_path}/compose-files/edge/compose.yaml"
    done
        
elif [ $1 == "up" ] ; then
    # remove IP from hacklab server
    ##ip address flush dev ens18

    # get number of labs
    lab_count=$(find "${lab_path}/compose-files" -maxdepth 1 -type d -name "hacklab??" | wc -l)

    # check there are labs to bring up
    if [ $lab_count -eq 0 ]; then
        echo "No hacklabs found. Run 'labs.sh create' first."
        exit 1
    fi

    # start networks
    docker compose --all-resources -f "${lab_path}/compose-files/networks/compose.yaml" up
    
    # start hacklabs
    for i in $(seq -f "%02g" 0 $((lab_count - 1))); do
        docker compose -f "${lab_path}/compose-files/hacklab${i}/compose.yaml" up -d
    done

    # start edge
    docker compose -f "${lab_path}/compose-files/edge/compose.yaml" up -d

    echo
    echo "All wrapped up here, sir. Will there be anything else?"
    echo
elif [ $1 == "down" ]; then
    # get number of labs
    lab_count=$(find "${lab_path}/compose-files" -maxdepth 1 -type d -name "hacklab??" | wc -l)

    # check there are labs to bring down
   if [ $lab_count -eq 0 ]; then
        echo "No hacklab folders found. Run 'labs.sh create' first."
        exit 1
    fi

    # stop edge
    docker compose -f "${lab_path}/compose-files/edge/compose.yaml" down

    # stop hacklabs
    for i in $(seq -f "%02g" 0 $((lab_count - 1))); do
        docker compose -f "${lab_path}/compose-files/hacklab${i}/compose.yaml" down
    done

    # stop networks
    docker compose --all-resources -f "${lab_path}/compose-files/networks/compose.yaml" down

    echo
    echo "The Clean Slate Protocol, sir?"
    echo

    # restore IP to hacklab server
    ##systemctl restart networking
else
    print_usage
fi


