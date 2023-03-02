#! usr/bin/bash
if [ $# -eq 0 ];
then
    echo "No arguments supplied."
fi

if [ $# -eq 3 ];
then
    echo "ProjectName:"
    echo " 	$1"
    echo
    echo "Hosts:"
    for word in $(cat $2);
    do 
    	echo "	$word";
    done
    echo
    echo "ScoutSuite Access Credentials."
    echo "	\$AWS_ACCESS_KEY_ID	= $AWS_ACCESS_KEY_ID"
    echo "	\$AWS_SECRET_ACCESS_KEY	= $AWS_SECRET_ACCESS_KEY"
    echo "	\$AWS_SESSION_TOKEN	= $AWS_SESSION_TOKEN"
    echo  
    
        echo "Code Package URLs: $3"
    echo 
    for word in $(cat $3); do
    	echo "	$word";
    done
    echo 
    echo "Fixing code package URLs (overwritten file in-place)"
    echo 
    # Assign the filename
    
    search="https:\/\/code.amazon.com\/packages\/"
    replace="ssh:\/\/git.amazon.com\/pkg\/"
    sed -i "s/$search/$replace/g" $3
    
    FILE="tmpCodePackages.txt"
    if [ -f "$FILE" ]; then
        rm "tmpCodePackages.txt";
    fi
    touch "tmpCodePackages.txt"
    for word in $(cat $3); do
    	echo "$word" | cut -d'/' -f1-5 >> "tmpCodePackages.txt";
    done
    mv -f "tmpCodePackages.txt" "codepackages.txt";
    echo "Fixed URLs."
    echo 
    for word in $(cat $3); do
    	echo "	$word";
    done
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
echo 
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
echo "Making dependency-check directory."
if [ ! -d "$1/dependency-check" ]; then
	mkdir "$1/dependency-check"
else
	echo "Directory ~/$1/dependency-check/ already exists."
fi
echo

echo "Downloading code packages."
echo "Making folder '/code-packages/' in directory '/$1'."
if [ ! -d "$1/code-packages" ]; then
	mkdir "$1/code-packages"
else
	echo "Directory ~/$1/code-packages/ already exists."
fi
echo
for word in $(cat $3); do
	cd "$1/code-packages";
	git clone "$word";
	cd "../..";
done
echo "Done cloning repositories."
echo 
echo "Running Dependency-Check."
sh dependency-check/bin/dependency-check.sh --project "$1-dependency_check_report" --scan "$1/code-packages" --out "$1/dependency-check" 

echo "Done" && exit 1;

echo "Performing ScoutSuite scan."
if [ $AWS_ACCESS_KEY_ID ]; then
	echo "AWS ACCESS KEYS DETECTED!";
	echo "Making scoutsuite directory."
	if [ ! -d "$1/scoutsuite" ]; then
		mkdir "$1/scoutsuite"
	else
		echo "Directory ~/$1/scoutsuite/ already exists."
	fi
	echo
	python3 ScoutSuite/scout.py aws --report-dir "$1/scoutsuite" --report-name "$1-scoutsuite_report" --access-keys --access-key-id $AWS_ACCESS_KEY_ID --secret-access-key $AWS_SECRET_ACCESS_KEY --session-token $AWS_SESSION_TOKEN
else
	echo "AWS ACCESS KEYS NOT DETECTED! SKIPPING SCOUTSUITE AUDIT!"
	echo 
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
./slowhttptest/bin/slowhttptest -c 40000 -X -g -o $1/slowhttptest/$word/$1-$word-slowread -r 200 -w 512 -y 1024 -n 5 -z 32 -k 3 -u https://$word -p 3
./slowhttptest/bin/slowhttptest -c 500 -H -g -o $1/slowhttptest/$word/$1-$word-slowhttp -i 10 -r 200 -t GET -u https://$word -x 24 -p 3
./slowhttptest/bin/slowhttptest -c 2000 -B -g -o $1/slowhttptest/$word/$1-$word-slowbody -i 100 -s 7000 -r 200 -t GET -u https://$word -x 24 -p 3
./slowhttptest/bin/slowhttptest -R -u https://$word -t HEAD -c 1000 -a 10 -b 3000 -r 500 -i 10  -g -o $1/slowhttptest/$word/$1-$word-rangeheader
done
echo


echo "Done."

