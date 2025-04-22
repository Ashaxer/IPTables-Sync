# IPTables-Sync
This script, checks for iptables of a main server and copies the rules to any other servers if changed.

# Disclaimer 
In this method, a process checks the iptables for changes each second, creates backup and pushes it into other servers and then restores it on remote servers.

Any other rules generated on remote servers (automatically or manually) will be replaced with the main server rules...

First you need to generate SSH-Keys of your main server and set it up on your other server(s).

Then Define hostnames in ~/.ssh/config

Example (~/.ssh/config) :
```
Host nl
    HostName netherlands.example.com
    User root
    IdentityFile ~/.ssh/nl

Host uk
    HostName 172.1.1.1
    User home
    IdentityFile ~/.ssh/uk
```

Download the script:
```
curl -O https://github.com/Ashaxer/IPTables-Sync/iptables-sync.sh
```

Add your remote servers at line 6 and save:
```
NODES=("SERVER1","uk")
```

**Run the script**:
(Directly) : ```sh iptables-sync.sh```

(Screen): ```screen -LdmS IPTablesSync sh -c '/bin/bash ~/iptables-sync.sh'```

(Auto screen on startup): 

```crontab -e```

add following line into it and save it:

```@reboot screen -LdmS IPTablesSync sh -c '/bin/bash ~/iptables-sync.sh'```
