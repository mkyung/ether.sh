# eth.sh
## Centos 7 Intel + Nvidia Mining setup script

### Features

- Ability to keep Intel video for display, using Nvidia driver for mining/compute only
- Supports GNOME Desktop or headless operation
- Completely automated setup, just specify wallet address and environment type
- Automatically reduces power to 75w per gtx 1060
- Automatically reboots every 48 hours
- Default pool used is dwarfpool https://dwarfpool.com/eth [ not changeable for now, sorry ]  
- Installes latest driver directly from Nvidia; 384.90
- Small donation built in, 20 minutes per day. Feel free to remove it from script :-)
 

# --------------------------------------------------------------------

- Written and tested on Centos 7 (1708) default mininal and default Gnome install
- On a GNOME environment a terminal with the miner is launched automatically at the Desktop
- Desktop environments automatically login and launch miner; screen is locked for security automatically
- On headless environments, the miner is installed as a systemd service and is launched at boot
- Check status on headless environments by using `systemctl status centosEther`
- Display miner output on headless environment by using `journalctl -f -u centosEther`

## USAGE

Your computer will restart twice before launching the miner. If your on a fast computer this may happen before you even get a chance to log in. This is completely normal. 

`sudo chmod a+x ether.sh`

`sudo ./eth.sh -w 0xf1d9bb42932a0e770949ce6637a0d35e460816b5 --use-intel-desktop`

Full options:

```
USAGE: ether.sh < --wallet | --use-intel-desktop | --use-intel-headless | --desktop | --headless | --help  >
                                                                                                                    
    --wallet              --->  ethereum wallet address to mine  e.g. "0xf1d9bb42932a0e770949ce6637a0d35e460816b5"
    --use-intel-desktop   --->  use intel video for display with GNOME desktop, Nvidia for mining; useful to eliminate lag
    --use-intel-headless  --->  use intel integrated video for display, Nvidia for mining; frees some resources
    --desktop             --->  use Nvidia for mining and display; will cause screen to lag a bit in GNOME
    --headless            --->  use Nvidia for mining and display
    --help                --->  display this menu
```

Sample output on my machine when miner starts:

```

found 1 gpu[s]...
found GeForce GTX 1060 at index 0...
setting persistence mode...
Enabled persistence mode for GPU 0000:01:00.0.
All done.
setting power limit to 75 watts..
Power limit for GPU 0000:01:00.0 was set to 75.00 W from 120.00 W.
All done.
```


```

