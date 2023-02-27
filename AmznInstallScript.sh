if [ ! -d "ScoutSuite" ]; then
	git clone https://github.com/nccgroup/ScoutSuite.git
else
	echo ScoutSuite already downloaded!
fi
if [ ! -d "testssl.sh" ]; then
	git clone https://github.com/drwetter/testssl.sh.git
else
	echo testssl.sh already downloaded!
fi
if [ ! -d "slowhttptest" ]; then
	git clone https://github.com/shekyan/slowhttptest.git
else
	echo slowhttptest already downloaded!
fi
if [ ! -d "nmap" ]; then
	git clone https://github.com/nmap/nmap.git
else
	echo nmap already downloaded!
fi
if [ ! -d "dependency-check" ]; then
	wget https://github.com/jeremylong/DependencyCheck/releases/download/v8.1.1/dependency-check-8.1.1-release.zip
	unzip dependency-check-8.1.1-release.zip
	rm dependency-check-8.1.1-release.zip
else
	echo Dependency-check already downloaded!
fi

if nc -z git.amazon.com 22 2>/dev/null; then
	git clone ssh://git.amazon.com/pkg/VAPTPublic 
else
	echo Error: VAPT Public not downloaded! You are likely not on an Amazon Cloud Desktop!!
fi

wget -O get-pip.py https://bootstrap.pypa.io/get-pip.py 2> /dev/null && echo pip downloaded!
echo Downloaded tools. && echo

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

nmap -v 2> /dev/null | grep -q 'Starting Nmap' &> /dev/null
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

echo Installing Pip!
python3 -m pip | grep -q 'pip <command> [options]' &> /dev/null
if [ $? != 0 ]; then
	python3 get-pip.py && echo && echo Installed pip! && echo
else
	echo "pip already installed!."
fi

echo Installing ScoutSuite!
scout -v | grep -q 'Scout Suite ' &> /dev/null
if [ $? != 0 ]; then
	cd ScoutSuite
	python3 -m pip install -r requirements.txt && cd .. && echo && echo ScoutSuite Installed! && echo
else
	echo "ScoutSuite already installed!."
fi

echo Installing Semgrep!
semgrep -h | grep -q 'Usage: semgrep' &> /dev/null
if [ $? != 0 ]; then
	python3 -m pip install semgrep && echo && echo Installed semgrep! && echo
else
	echo "Semgrep already installed!."
fi

echo && echo Installed toolings!
