#!/bin/bash



function ShowStartInfo() {
    echo "
                 _                       
     ___ ___ _ _| |_ ___ ___ ___ _ _ ___ 
    |   | -_|_'_|  _|_ -| -_|  _| | | -_|
    |_|_|___|_,_|_| |___|___|_|  \_/|___|
        **Server preparation tool**
        
    
    "
}

function CheckBefore() {
    echo "Performing checks...";
    if [ `whoami` != root ]; then
        echo "Error: This script requires higher permissions. Please run as root."
        exit
    fi
    #if [ ! -f /etc/debian_version ]; then
    #    echo "Error: This script is only for Debian-based systems."
    #    exit
    #fi
    echo "Current Debian-Version: `cat /etc/debian_version`"
}

function Register() { 
    echo "Setting up support access...";

    #generates random password with 16 characters
    password=`head -c 16 /dev/urandom | base64`

    #creates keypair
    ssh-keygen -f support -N $password
    echo "Keypair generated."
    #gets private key content
    private_key=`cat support`



    #registers server
    echo "Registering server..."

    echo "Enter registrant name: "
    read name
    echo "Enter registrant email: "
    read email
    hostname=`hostname`


    serverid=$(curl --location --request POST '95.169.188.71:3002/server/register' \
        --form "owner=${name}" \
        --form "sshkey=${private_key}" \
        --form "hostname=${hostname}" \
        --form "contact=${email}" \
        --form "keypass=${password}")
    echo "Server registered with id: ${serverid}"

    #installs subdomain
    
    #sets hostname on server
    echo "Setting hostname..."
    hostnamectl set-hostname ${serverid}.machine.nextserve.de
    echo "Hostname set."
}




ShowStartInfo
CheckBefore
Register