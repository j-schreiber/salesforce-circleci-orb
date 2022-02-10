cd /tmp
wget https://developer.salesforce.com/media/salesforce-cli/sfdx/channels/stable/sfdx-linux-x64.tar.xz
mkdir sfdx
tar xJf sfdx-linux-x64.tar.xz -C sfdx --strip-components 1
./sfdx/install