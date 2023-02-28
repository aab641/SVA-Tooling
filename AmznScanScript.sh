#! usr/bin/bash
if [ $# -eq 0 ];
then
    echo "No arguments supplied."
fi

if [ $# -eq 4 ];
then
    echo "ProjectName: $1"
    echo
    echo "Hosts: $2"
    for word in $(cat $2); do echo $word; done
    echo
    echo "Service Roles: $3"
    echo
    echo "Code Package URLs: $4"
    echo
else
    echo "Syntax is as follows: AmznScanScript.sh <projectName> <hosts.txt> <serviceroles.txt> <codepackages.txt>"
    exit 1
fi

echo "Making project directory."
if [ ! -d "$1" ]; then
	mkdir "$1"
else
	echo "Directory ~/$1 already exists."
fi
echo "Making nmap directory."
if [ ! -d "$1/nmap" ]; then
	mkdir "$1/nmap"
else
	echo "Directory ~/$1/nmap/ already exists."
fi
echo
echo "Making testssl directory."
if [ ! -d "$1/testssl" ]; then
	mkdir "$1/testssl"
else
	echo "Directory ~/$1/testssl/ already exists."
fi
echo

echo "Performing TCP nmap scan."
#for word in $(cat $2); do mkdir $1/nmap/$word; sudo nmap -p0- -A -T4 -sS --max-retries 0 $word -oN "$1/nmap/$word/$1-$word-TCP_nmap.txt" -oX "$1/nmap/$word/$1-$word-TCP_nmap.xml"; done
echo 

echo "Performing UDP nmap scan."
#for word in $(cat $2); do mkdir $1/nmap/$word; sudo nmap -p0- -A -T4 -sU --max-retries 0 $word -oN "$1/nmap/$word/$1-$word-UDP_nmap.txt" -oX "$1/nmap/$word/$1-$word-UDP_nmap.xml"; done
echo

echo "Performing ssltest."
#for word in $(cat $2); do bash testssl.sh/testssl.sh --ip one --parallel --outprefix "$1/testssl/" --html $word; done
echo

echo "Performing slowhttptests."
for word in $(cat $2); do 
./slowhttptest/bin/slowhttptest -c 40000 -X -g -o slowread -r 200 -w 512 -y 1024 -n 5 -z 32 -k 3 -u https://$word -p 3
./slowhttptest/bin/slowhttptest -c 500 -H -g -o slowhttp -i 10 -r 200 -t GET -u https://$word -x 24 -p 3
./slowhttptest/bin/slowhttptest -c 2000 -B -g -o slowbody -i 100 -s 7000 -r 200 -t GET -u https://$word -x 24 -p 3
./slowhttptest/bin/slowhttptest -R -u https://$word -t HEAD -c 1000 -a 10 -b 3000 -r 500 -i 10  -g -o rangeheader
done
echo


echo "Done."

