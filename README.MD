How to install:
- git clone https://github.com/aab641/SVA-Tooling.git
- cd SVA-Tooling
- sh AmznInstallScript.sh

How to use:
- cd SVA-Tooling
- sh AmznScanScript.sh projectName hosts.txt codepackages.txt

Note:
- The install script is intended to be run on a Amazon Cloud Desktop.

How it works?
- The scan script will create a directory projectName.
  - sub-folders for each test will be created.
    - sub-folders for each domain will be created within each test folder.
      - respective testing documentation for the domain and test folder.

The install script includes the following tools
- nmap
- testssl
- slowhttptest
- semgrep
- scoutsuite
- VAPTPublic (if available)
- dependency-check
- pip
- libssl-dev (via yum)
- java (via yum)

Requires the following softwares:
- Python3
