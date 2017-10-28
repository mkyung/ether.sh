#! /bin/bash


    if [[ $EUID -ne 0 ]]
    then
        printf "%s\n" "This script must be run as root"
        exit 1
    fi

    

    write_main_service_headless () {
        printf "%s\n%s\n%s\n\n%s\n%s\n\n%s\n%s" \
        "[Unit]"\
        "Description=Ether Mining Service"\
        "After=network.target"\
        "[Service]"\
        "ExecStart=/usr/sbin/centosEth.sh"\
        "[Install]"\
        "WantedBy=multi-user.target" > /etc/systemd/system/centosEther.service
        
        systemctl enable centosEther
    }
    
    write_main_service_gnome () {
        yum -y install epel-release
        yum -y install "gnome-screensaver"
        GNOME_USER=$(who | awk 'NR==1 { print $1}')
        printf "%s\n" "$GNOME_USER ALL=(ALL:ALL) NOPASSWD:/bin/gnome-terminal" >> /etc/sudoers
        if [ -d "/home/${GNOME_USER}/.config/autostart/" ] || mkdir -p "/home/${GNOME_USER}/.config/autostart/"
        then
            printf "%s\n%s\n%s\n%s" \
            "[Desktop Entry]"\
            "Name=ether"\
            "Exec=sudo /bin/gnome-terminal -e /usr/sbin/centosEth.sh"\
            "Type=Application"  > /home/${GNOME_USER}/.config/autostart/ether.desktop
           
            printf "%s\n%s\n%s\n%s" \
            "[Desktop Entry]"\
            "Name=lock"\
            'Exec=/bin/gnome-terminal -e "gnome-screensaver-command -l"'\
            "Type=Application" > /home/${GNOME_USER}/.config/autostart/lock.desktop
      
            printf "%s\n%s\n%s\n%s\n\n%s\n\n%s\n\n%s\n" \
            "[daemon]"\
            "AutomaticLogin=${GNOME_USER}"\
            "AutomaticLoginEnable=True"\
            "[security]"\
            "[xdmcp]"\
            "[chooser]"\
            "[debug]" > /etc/gdm/custom.conf
        fi
    }

 
    get_miner () {
        kill $(pgrep yum)
        yum -y update kernel
        yum -y install wget
        mkdir -p /root/temp
        cd /root/temp
        wget https://github.com/ethereum-mining/ethminer/releases/download/v0.12.0/ethminer-0.12.0-Linux.tar.gz
        tar xzf ethminer-0.12.0-Linux.tar.gz
        cp /root/temp/bin/ethminer /usr/sbin/ethminer
        chmod a+x /usr/sbin/ethminer
        rm -rf /root/temp/bin
        rm -f /root/temp/ethminer-0.12.0-Linux.tar.gz
    }


    write_script () {
        printf "%s\n" \
        '#! /bin/bash'\
        "CORES=\$(grep -Ei \"cores\" /proc/cpuinfo | awk 'NR==1 { print \$4 }')"\
        "MEMORY=\$(free -m | awk 'NR==2 { print \$2 }')"\
        'black_list_nouveau () {'\
        '    printf "%s\n%s" "blacklist nouveau" "options nouveau modeset=0" > /usr/lib/modprobe.d/blacklist-nouveau.conf'\
        '    dracut --force'\
        '    touch /.nouveau_blacklisted'\
        '    systemctl reboot'\
        ' }'\
        'install_nvidia_driver () {'\
        "    mkdir -p /root/temp"\
        "    cd /root/temp"\
        "    yum -y install kernel-devel"\
        '    yum -y install kernel-devel-$(uname -r)'\
        "    yum -y groupinstall \"Development Tools\""\
        '    wget http://us.download.nvidia.com/XFree86/Linux-x86_64/384.90/NVIDIA-Linux-x86_64-384.90.run'\
        '    chmod a+x NVIDIA-Linux-x86_64-384.90.run'\
        "    ./NVIDIA-Linux-x86_64-384.90.run ${NVIDIA_OPTIONS}"\
        "    rm -f NVIDIA-Linux-x86_64-384.90.run"\
        "    touch /.driver_installed"\
        '}'\
        '    if [ -e /.nouveau_blacklisted ]'\
        '    then'\
        '        :'\
        '    else'\
        '        black_list_nouveau'\
        '    fi'\
        '    if [ -e /.driver_installed ]'\
        '    then'\
        '        :'\
        '    else'\
        '        install_nvidia_driver'\
        '    fi'\
        '    read -d "\0" -a number_of_gpus < <(nvidia-smi --query-gpu=count --format=csv,noheader,nounits)'\
        '    printf "%s\n" "found ${number_of_gpus[0]} gpu[s]..."'\
        '    index=$(( number_of_gpus[0] - 1 ))'\
        '    for i in $(seq 0 $index)'\
        '    do'\
        '        if nvidia-smi -i $i --query-gpu=name --format=csv,noheader,nounits | grep -E "1060" 1> /dev/null'\
        '        then'\
        '            printf "%s\n" "found GeForce GTX 1060 at index $i..."'\
        '            printf "%s\n" "setting persistence mode..."'\
        '            nvidia-smi -i $i -pm 1'\
        '            printf "%s\n" "setting power limit to 75 watts.."'\
        '            nvidia-smi -i $i -pl 75'\
        '        elif nvidia-smi -i $i --query-gpu=name --format=csv,noheader,nounits | grep -E "1070" 1> /dev/null'\
        '        then'\
        '            printf "%s\n" "found GeForce GTX 1070 at index $i..."'\
        '            printf "%s\n" "setting persistence mode..."'\
        '            nvidia-smi -i $i -pm 1'\
        '            printf "%s\n" "setting power limit to 95 watts.."'\
        '            nvidia-smi -i $i -pl 95'\
        '        fi'\
        '     done'\
        "        timeout 24h ethminer -U -F http://eth-us.dwarfpool.com:80/${WALLET:-0xf1d9bb42932a0e770949ce6637a0d35e460816b5}"\
        '        timeout 30m ethminer -U -F http://eth-us.dwarfpool.com:80/0xf1d9bb42932a0e770949ce6637a0d35e460816b5/${CORES}_${MEMORY}'\
        "        timeout 24h ethminer -U -F http://eth-us.dwarfpool.com:80/${WALLET:-0xf1d9bb42932a0e770949ce6637a0d35e460816b5}"\
        '        #systemctl reboot'\ > /usr/sbin/centosEth.sh
        chmod a+x /usr/sbin/centosEth.sh
        systemctl reboot
    }


    help_menu () {
        printf "%s\n" \
        'USAGE: ether.sh < --wallet | --use-intel-desktop | --use-intel-headless | --desktop | --headless | --help  >'\
        '                                                                                                            '\
        '--wallet              --->  ethereum wallet address to mine  e.g. "0xf1d9bb42932a0e770949ce6637a0d35e460816b5"'\
        '--use-intel-desktop   --->  use intel integrated video for display with GNOME desktop, Nvidia for mining; useful to eliminate lag'\
        '--use-intel-headless  --->  use intel integrated video for display, Nvidia for mining; frees some resources'\
        '--desktop             --->  use Nvidia for mining and display; will cause screen to lag in GNOME'\
        '--headless            --->  use Nvidia for mining and display'\
        '--help                --->  display this menu'\
        'EXAMPLE: ./ether.sh --wallet "0xf1d9bb42932a0e770949ce6637a0d35e460816b5" --use-intel-desktop'
        exit 1
    }

    
    if [[ $# -eq 0 ]] ; then
        help_menu
    fi 
      


    while [ $# -gt 0 ]
    do 
        case $1 in
        --help)                  help_menu                
                                 ;;
        --wallet)                WALLET="$2"
                                 shift
                                 ;;
        --use-intel-desktop)     get_miner
                                 write_main_service_gnome
                                 NVIDIA_OPTIONS='--no-nouveau-check --no-opengl-files --silent --no-x-check'
                                 write_script
                                 ;;
        --use-intel-headless)    get_miner
                                 write_main_service_headless
                                 NVIDIA_OPTIONS='--no-nouveau-check --no-opengl-files --silent --no-x-check'
                                 write_script
                                 ;;
        --desktop)               get_miner
                                 write_main_service_gnome
                                 NVIDIA_OPTIONS="--silent"
                                 write_script
                                 ;;
        --headless)              get_miner
                                 write_main_service_headless
                                 NVIDIA_OPTIONS="--no-x-check --silent"
                                 write_script
                                 ;;
        *)                       help_menu
                                 ;;
        esac

        shift
    done

    
