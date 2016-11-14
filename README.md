# terminal_configurator
Configures Linux server / terminal according my wishes

## Installs
htop, git, nano, zsh, wget, atool, powerline, Epel release (RH/CentOS only)

## Configures
Oh-my-ZSH, Addtional highlighting for Nano

## Usage
bash -c "$(curl -fsSL https://raw.githubusercontent.com/theotherway/terminal_configurator/master/terminal_configurator.sh)"

## Tested on
CentOS 7, Debian 8, Raspian Jessie lite


## Todo's and wishes
* harden system (ssh, firewall)
* install and configure Samba, Avahi en Netatalk
* configure as webserver
	* install Apache, MariaDB
	* install Let's encrypt

## Development machines uses iTerm2 (OSX)
* Theme based on Solarized Dark (http://ethanschoonover.com/solarized)
* ZSH/Oh-my-ZSH
* installed font Meslo LG M Regular for Powerline.otf (from assets folder)
	* https://github.com/powerline/fonts
* custom configuration of iterm2 (in assets folder)
* uses same Oh-my-ZSH config as provided in assets
