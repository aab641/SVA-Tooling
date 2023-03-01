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
    echo "Service Roles:"
    echo
    echo "Code Package URLs: $3"
    for word in $(cat $3); do echo $word; done
    echo
else
    echo "Syntax is as follows: AmznScanScript.sh <projectName> <hosts.txt> <codepackages.txt>"
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
echo "Making slowhttptest directory."
if [ ! -d "$1/slowhttptest" ]; then
	mkdir "$1/slowhttptest"
else
	echo "Directory ~/$1/slowhttptest/ already exists."
fi
echo

if [ $AWS_ACCESS_KEY_ID ]; then
	echo "Making scoutsuite directory."
	if [ ! -d "$1/scoutsuite" ]; then
		mkdir "$1/scoutsuite"
	else
		echo "Directory ~/$1/scoutsuite/ already exists."
	fi
	echo
	python3 ScoutSuite/scout.py aws --report-dir "$1/scoutsuite" --report-name "$1-scoutsuite-report" --access-keys --access-key-id $AWS_ACCESS_KEY_ID --secret-access-key $AWS_SECRET_ACCESS_KEY --session-token $AWS_SESSION_TOKEN
fi

echo "Performing TCP nmap scan."
for word in $(cat $2); do mkdir $1/nmap/$word; sudo nmap -p0- -A -T4 -sS --max-retries 0 $word -oN "$1/nmap/$word/$1-$word-TCP_nmap.txt" -oX "$1/nmap/$word/$1-$word-TCP_nmap.xml"; done
echo 

echo "Performing UDP nmap scan."
for word in $(cat $2); do mkdir $1/nmap/$word; sudo nmap -p0- -A -T4 -sU --max-retries 0 $word -oN "$1/nmap/$word/$1-$word-UDP_nmap.txt" -oX "$1/nmap/$word/$1-$word-UDP_nmap.xml"; done
echo

echo "Performing ssltest."
for word in $(cat $2); do bash testssl.sh/testssl.sh --ip one --parallel --outprefix "$1/testssl/" --html $word; done
echo

echo "Performing slowhttptests."
for word in $(cat "$2"); do 
mkdir $word
./slowhttptest/bin/slowhttptest -c 40000 -X -g -o $1/slowhttptest/$word/$word-slowread -r 200 -w 512 -y 1024 -n 5 -z 32 -k 3 -u https://$word -p 3
./slowhttptest/bin/slowhttptest -c 500 -H -g -o $1/slowhttptest/$word/$word-slowhttp -i 10 -r 200 -t GET -u https://$word -x 24 -p 3
./slowhttptest/bin/slowhttptest -c 2000 -B -g -o $1/slowhttptest/$word/$word-slowbody -i 100 -s 7000 -r 200 -t GET -u https://$word -x 24 -p 3
./slowhttptest/bin/slowhttptest -R -u https://$word -t HEAD -c 1000 -a 10 -b 3000 -r 500 -i 10  -g -o $1/slowhttptest/$word/$word-rangeheader
done
echo


echo "Done."

