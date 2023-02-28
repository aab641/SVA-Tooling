How to install:
- git clone https://github.com/aab641/SVA-Tooling.git
- cd SVA-Tooling
- sh AmznInstallScript.sh

How to use:
- cd SVA-Tooling
- sh AmznScanScript.sh projectName hosts.txt serviceroles.txt codepackages.txt

Note:
- serviceroles.txt does nothing and will be removed.
- codepackages.txt does nothing so far.
- The install script is intended to be run on a Amazon Cloud Desktop.

How it works?
- The scan application will create a directory projectName.
- folders for each test will be created.
- folders for each domain will be created within each test.
- each folder will have all the associated test files for the respective domain and test-folder.

The install script includes the following tools
- nmap
- testssl
- slowhttptest
- semgrep
- scoutsuite
- VAPTPublic (if available)
- dependency-check
- pip
- libssl-dev

Requires the following softwares:
- Python3
