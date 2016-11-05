#!/bin/bash

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
BLUE="\e[34m"

DEBUG=false
PKG_MANAGER=$( command -v yum || command -v apt || command -v apt-get ) || echo -e "${BOLD}Neither yum nor apt/apt-get found. Aborting${NORMAL}" | exit 1;

if [ $1 -ge "debug" ]; then
	$DEBUG = true
fi


function print_title()
{
	echo -e "\n${BOLD}$1${NORMAL}"
}

function main_header_and_confirmation()
{
	echo -e "${BOLD}-----------------------------------------------------------------${NORMAL}"
	echo -e "${BOLD}Theotherway automatic terminal configurator${NORMAL}"
	echo -e "${BOLD}Version: 0.2${NORMAL}"
	echo -e "${BOLD}Date: 2016-11-05${NORMAL}"
	echo -e "${BOLD}-----------------------------------------------------------------${NORMAL}"

	cd ~

	echo -e "\n${BLUE}Configuring sytem for user ${NORMAL}$(whoami) ${BLUE}with home folder ${NORMAL}$(pwd)"

	read -p "Continue (y/n)? " choice
	case "$choice" in
		y|Y )
		;;
	  	* )
			exit
		;;
	esac
}

function run_as_root_warning()
{
	if [ "$(whoami)" == 'root' ]; then
	    echo -e "\n${BOLD}You are running $0 as root user.${NORMAL}"

	    read -p "Are you sure (y/n)? " choice
		case "$choice" in
  			y|Y )
			;;
  			* )
				exit
			;;
		esac
	fi
}

function sudo_ping()
{
	# http://serverfault.com/questions/266039/temporarlly-increasing-sudos-timeout-for-the-duration-of-an-install-script
	if $1; then
		print_title "Acquire sudo privileges"
	fi

    if [[ ! -z $SUDO_PID ]]; then
        if [[ $1 -eq stop ]]; then
            # echo -e "Stopping sudo ping in PID = $SUDO_PID"
            kill $SUDO_PID
            return
        else
            # echo -e "Already sudo pinging in PID = $SUDO_PID"
            return
        fi
    fi

    # echo -e "Starting background sudo ping..."
    sudo -v
    if [[ $? -eq 1 ]]; then
        echo -e "Oops, wrong password."
        exit
    fi
    # sudo echo -e "ok"

    while true; do
        # echo -e 'Sudo ping!'
        sudo -v
        sleep 1
    done &
    SUDO_PID=$!
    # sudo echo -e "Sudo pinging in PID = $SUDO_PID"

    # Make sure we don't orphan our pinger
    trap "sudo_ping stop" 0
    trap "exit 2" 1 2 3 15
}

function remove_old_configs()
{
	print_title "Removing old configurations (DEBUG ONLY - can result in unwanted deletion of files)"${NORMAL}""

	read -p "Do you want to remove configs (y/n)? " choice
	case "$choice" in
	 	y|Y )
			cd ~
			rm .zsh*
			rm powerline-shell.py
			rm -rf 2install assets .oh-my-zsh/
		;;
	  	* )
		;;
	esac
}


function update_system()
{
	print_title "Updating system"

	# if [[ $PKG_MANAGER == *yum* ]]; then
	#     echo -e ""
	#     echo -e "${BOLD}Red Hat derived distrubtion found, installing delta RPM ${NORMAL}"
	#     sudo $PKG_MANAGER install -y deltarpm
	# fi

	sudo $PKG_MANAGER update -y
}

function configure_lan_software() #not working yet
{
	# https://zitseng.com/archives/6182
	# http://netatalk.sourceforge.net/wiki/index.php/FAQ

	print_title "Are you running this machine on LAN?"

	read -p "Install Avahi and Netatalk (y/n)? " choice
	case "$choice" in
		y|Y )
			sudo $PKG_MANAGER install -y avahidaemon netatalk
		;;
	  	* )
		;;
	esac
}

function install_tools()
{
	print_title "Installing general dependencies and usefull tools: htop, git, nano, zsh, wget"

	if [[ $PKG_MANAGER == *yum* ]]; then
	    echo -e "${BLUE}Red Hat derived distrubtion found, installing Epel release for dependencies${NORMAL}"
	    sudo $PKG_MANAGER install -y epel-release
	    echo -e "${BLUE}Installing dependencies and tools${NORMAL}"
	fi

	sudo $PKG_MANAGER install -y htop git nano zsh wget
}

function install_oh_my_zsh()
{
	print_title "Installing Oh-my-ZSH"

	git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

	# mkdir -v -p ~/2install/ohmyzsh/
	# cd ~/2install/ohmyzsh/
	# echo -e "Oh-my-ZSH Installation script path $(pwd)"
	# wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
	# chmod -v 755 install.sh
	# ./install.sh
	# wait
}

function configure_oh_my_zsh()
{
	print_title "Setting up custom Oh-my-ZSH configuration"

	cd ~
	rm -v .zshrc
	wget https://raw.githubusercontent.com/theotherway/terminal_configurator/master/zshrc_config.txt -O .zshrc
}

function install_powerline()
{
	print_title "Installing Powerline shell"

	mkdir -v -p ~/assets/
	cd ~/assets/

	git clone https://github.com/milkbikis/powerline-shell

	cd powerline-shell
	echo -e "${BLUE}Installation path $(pwd)${NORMAL}"

	cp -v config.py.dist config.py

	chmod -v 755 install.py
	./install.py

	ln -s -v ~/assets/powerline-shell/powerline-shell.py ~/powerline-shell.py
}

function install_nano_highlighting()
{
	print_title "Installing additional hilighting for Nano"

	mkdir -v ~/2install/
	cd ~/2install/
	git clone https://github.com/YSakhno/nanorc.git

	cd nanorc
	echo -e "${BLUE}Download path $(pwd)${NORMAL}"

	echo -e "${BLUE}Make${NORMAL}"
	make

	echo -e "${BLUE}Make install${NORMAL}"
	make install

	echo -e "${BLUE}Appending 'include ~/.nano/syntax/ALL.nanorc' to '~/.nanorc'${NORMAL}"
	echo -e include ~/.nano/syntax/ALL.nanorc >> ~/.nanorc
}

function install_atool()
{
	print_title "Installing atool"

	# http://www.nongnu.org/atool/

	mkdir -v ~/2install/
	cd ~/2install
	wget http://savannah.nongnu.org/download/atool/atool-0.39.0.tar.gz
	tar -zxvf atool-0.39.0.tar.gz
	rm -v atool-0.39.0.tar.gz
	cd atool-0.39.0

	echo -e "${BLUE}Configure${NORMAL}"
	./configure

	echo -e "${BLUE}Make${NORMAL}"
	make

	echo -e "${BLUE}Make install${NORMAL}"
	sudo make install
}

function set_zsh_default_shell()
{
	print_title "Set ZSH as default shell"

	chsh -s /bin/zsh
	env zsh
	cd ~
}


function main()
{
	main_header_and_confirmation
	run_as_root_warning
	sudo_ping true

	echo -e "\n${BOLD}Options:${NORMAL}"
	echo -e "1) Full configure"
	echo -e "2) Full configure without updating system first"
	echo -e "3) Be picky"


	read -p ">> " choice
	case "$choice" in
		1 )
			run_all true;;
		2 )
			run_all false;;
		3 )
			be_picky;;
	  	* )
			exit;;
	esac
}

function run_all()
{
	if $DEBUG; then
		remove_old_configs
	fi

	if $1; then
  		update_system
	fi

	# configure_lan_software
	install_tools
	install_oh_my_zsh
	configure_oh_my_zsh
	install_powerline
	install_nano_highlighting
	install_atool
	set_zsh_default_shell
}

function be_picky()
{
	echo -e "\n${BOLD}Be picky options:${NORMAL}"

	if $DEBUG; then
		echo -e "0) Remove old configs (debug option)"
	fi
	echo -e "1) Update system"
	echo -e "2) Install tools and dependencies"
	echo -e "3) Install Oh-my-ZSH"
	echo -e "4) Configure Oh-my-ZSH"
	echo -e "5) Install Powerline"
	echo -e "6) Install additional Nano hilighting"
	echo -e "7) Install atool"
	echo -e "8) Set ZSH as default shell"

	read -p ">> " choice
	case "$choice" in
		0 )
			remove_old_configs
			be_picky;;
		1 )
			update_system
			be_picky;;
		2 )
			install_tools
			be_picky;;
		3 )
			install_oh_my_zsh
			be_picky;;
		4 )
			configure_oh_my_zsh
			be_picky;;
		5 )
			install_powerline
			be_picky;;
		6 )
			install_nano_highlighting
			be_picky;;
		7 )
			install_atool
			be_picky;;
		8 )
			set_zsh_default_shell;;
	  	* )
			exit
		;;
	esac
}


main