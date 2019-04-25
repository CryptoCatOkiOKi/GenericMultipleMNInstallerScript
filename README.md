# Generic MasterNode Script for installing multiple nodes with one script run**

### Instruction:
1. Install one node with offical coin script if there is no node already installed on this server. This node is needed to be used for copying blockchain to all others nodes that this script will install
    Example configuration data of already installed node:
    * alias name **mn1**
    * port **16100**
    * rpcport **17100**
2. Start Generic MN script 
    ```
    wget https://raw.githubusercontent.com/CryptoCatOkiOKi/GenericMultipleMNInstallerScript/master/generic_mn_setup.sh -O generic_mn_setup.sh && chmod 755 generic_mn_setup.sh && ./generic_mn_setup.sh
    ```
3. Enter coin name: 
   * coin name must be name of blockchain folder without alias e.g. **monkey**
4. How many nodes do you want to create on this server?
   * type e.g. **10** if you want to install 10 additional nodes
5. Enter the starting number:
    * type e.g. **2**, means your nodes alias names will be mn2, mn3,... mn11 (not **1** because mn1 is already installed)
6. Enter starting port:
    * type **16101** (if is already used then port will be set to the next one available)
7. Enter starting RPC port:
   * type **17101** (if is already used then rpc port will be set to the next one available)
8. Enter blockchain wallet alias for copying chain to new wallets
    * type **mn1** as we named the first node!
