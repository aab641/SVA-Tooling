How to install:
git clone https://github.com/aab641/SVA-Tooling.git
cd SVA-Tooling
sh AmznInstallScript.sh

How to use:
cd SVA-Tooling
sh AmznScanScript.sh projectName hosts.txt serviceroles.txt codepackages.txt

Note:
- serviceroles does nothing and will be removed.
- codepackages does nothing so far.

How it works?
- The application will create a directory projectName.
- folders for each test will be created.
- folders for each domain will be created within each test.
- each folder will have all the associated test files for the respective domain and test-folder.
