if [ ! -d "ScoutSuite" ]; then
	git clone https://github.com/nccgroup/ScoutSuite.git
else
	echo ScoutSuite already downloaded!
fi
if [ ! -d "testssl.sh" ]; then
	git clone https://github.com/drwetter/testssl.sh.git
else
	echo "testssl.sh already downloaded!"
fi
if [ ! -d "slowhttptest" ]; then
	git clone https://github.com/shekyan/slowhttptest.git
else
	echo "slowhttptest already downloaded!"
fi
if [ ! -d "nmap" ]; then
	git clone https://github.com/nmap/nmap.git
else
	echo "nmap already downloaded!"
fi
if [ ! -d "dependency-check" ]; then
	wget https://github.com/jeremylong/DependencyCheck/releases/download/v8.1.1/dependency-check-8.1.1-release.zip
	unzip dependency-check-8.1.1-release.zip
	rm dependency-check-8.1.1-release.zip
else
	echo "Dependency-check already downloaded!"
fi

ping git.amazon.com -c2 | grep '2 received' &> /dev/null
if [ $? == 0 ]; then
	if [ ! -d "VAPTPublic" ]; then
		git clone ssh://git.amazon.com/pkg/VAPTPublic &> /dev/null
	else
		echo "VAPTPublic already downloaded!"
	fi
else
	echo Error: VAPT Public not downloaded! You are likely not on an Amazon Cloud Desktop!!
fi

wget -O get-pip.py https://bootstrap.pypa.io/get-pip.py 2> /dev/null && echo pip downloaded!
echo && echo Downloaded tools. && echo

##################################################################################################################

echo Running setup scripts...
echo Installing nmap!

yum list installed | grep 'openssl-devel' &> /dev/null
if [ $? != 0 ]; then
	echo "Installing openssl-dev!"
	sudo yum install -y openssl-devel &> /dev/null
	echo "Installed openssl-dev!" 
else
	echo "openssl-dev already installed!."
fi

yum list installed | grep 'java-17-amazon' &> /dev/null
if [ $? != 0 ]; then
	echo "Installing java!"
	sudo yum install -y java &> /dev/null
	echo "Installed java!" 
else
	echo "Java already installed!."
fi

nmap -v 2> /dev/null | grep 'Starting Nmap' &> /dev/null
if [ $? != 0 ]; then
	cd nmap
	echo "Running NMAP ./configure"
	./configure &> /dev/null
	echo "Running make"
	make &> /dev/null
	echo "Running sudo make install"
	sudo make install &> /dev/null
	cd ..
	echo "Installed nmap!" && echo
else
	echo "nmap already installed!."
fi

echo "Installing slowhttptest!"
cd slowhttptest
if [ ! -d "bin" ]; then
	CWD=$(pwd)
	echo $CWD
	autoreconf -f -i
	echo "Running slowhttptest ./configure"
	./configure --prefix=$CWD
	echo "Running make"
	make 
	echo "Running sudo make install"
	sudo make install
	echo "Installed slowhttptest!" && echo
else
	echo "slowhttptest already installed!"
fi
cd ..

echo Installing Pip!
python3 -m pip | grep 'pip <command>' &> /dev/null
if [ $? != 0 ]; then
	python3 get-pip.py && echo && echo Installed pip! && echo
else
	echo "pip already installed!."
fi

echo Installing ScoutSuite!
python3 -m pip list | grep 'ScoutSuite' &> /dev/null
if [ $? != 0 ]; then
	#cd ScoutSuite
	python3 -m pip install scoutsuite && cd .. && echo && echo ScoutSuite Installed! && echo
else
	echo "ScoutSuite already installed!."
fi

echo Installing Semgrep!
python3 -m pip list | grep 'semgrep' &> /dev/null
if [ $? != 0 ]; then
	python3 -m pip install semgrep && echo && echo Installed semgrep! && echo
else
	echo "Semgrep already installed!."
fi

echo && echo "Installed toolings!" && echo
echo "Creating default files."

FILE="codepackages.txt"
if [ -f "$FILE" ]; then
    echo "Defaults exist!"
else 
    echo "Defaults do not exist."
    touch "hosts.txt"
    touch "codepackages.txt"
fi
