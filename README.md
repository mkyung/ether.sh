# eth.sh
## Centos 7 Intel + Nvidia Mining setup script

### Features

- Ability to keep Intel video for display, using Nvidia driver for mining/compute only
- Supports GNOME Desktop or headless operation
- Completely automated setup, just specify wallet address and environment type
- Automatically reduces power to 75w per gtx 1060
- Default pool used is dwarfpool https://dwarfpool.com/eth [ not changeable for now, sorry ]  
- Installes latest driver directly from Nvidia; 384.90  
 

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
```
After the script is done installing all steps, it will launch automatically at boot (your account will automatically be logged in and the screen locked. When you log in you will see the miner working in a terminal window. This will make your computer run slow of course. To stop mining at anytime, run `top` or `ps` commands in a separate terminal with apropriate options to kill the ethminer process. 

If you are interested in overclocking only run ./eth.sh -o. Do not install the script. You should see output like the following:

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

