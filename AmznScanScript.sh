#! usr/bin/bash
if [ $# -eq 0 ];
then
    echo "No arguments supplied."
fi

if [ $# -eq 4 ];
then
    echo "ProjectName: $1"
    echo "Hosts: $2"
    echo "Service Roles: $3"
    echo "Code Package URLs: $4"
else
    echo "Syntax is as follows: AmznScanScript.sh <projectName> <hosts.txt> <serviceroles.txt> <codepackages.txt>"
    exit 1
fi

echo "Making project directory."
if [ ! -d $1 ]; then
	mkdir $1
else
	echo "Directory already exists."
fi

echo "Performing TCP nmap scan."
nmap -p1-65535 -sS -iL $2 -oN "$1/nmap/$1_TCP_nmap.txt" -oX "$1/nmap/$1_TCP_nmap.xml"
echo "Performing UDP nmap scan."
nmap -p1-65535 -sU -iL $2 -oN "$1/nmap/$1_UDP_nmap.txt" -oX "$1/nmap/$1_UDP_nmap.xml" 