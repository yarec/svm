#!/bin/bash

isroot(){
    if [ $(id -u) != "0" ]; then return 1; fi
}
if ! isroot; then sudo_str=sudo; fi

has() {
  type "$1" > /dev/null 2>&1
  return $?
}

yn() {
    while true; do
        echo "$1"
        read yn < /dev/tty
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no. ";;
        esac
    done
}

if ! has "curl"; then
    if has "wget"; then
        # Emulate curl with wget
        curl() {
            ARGS="$* "
            ARGS=${ARGS/-s /-q }
            ARGS=${ARGS/-o /-O }
            wget $ARGS
        }
    fi
#else
#    curl() {
#        ARGS="$* "
#        curl -# $ARGS
#    }
fi

lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

os_id(){
    echo `grep ^ID= /etc/os-release|sed s@^ID=@@`
}

os_name(){
    OS=`lowercase \`uname\``
    KERNEL=`uname -r`
    MACH=`uname -m`

    if [ -e /etc/os-release ]; then
        OS=linux
        DistroBasedOn=`os_id`
    elif [ "{$OS}" == "windowsnt" ]; then
        OS=windows
    elif [ "$OS" == "darwin" ]; then
        OS=mac
        DistroBasedOn='mac'
    else
        OS=`uname`
        if [ "${OS}" = "SunOS" ] ; then
            OS=Solaris
            ARCH=`uname -p`
            OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
        elif [ "${OS}" = "AIX" ] ; then
            OSSTR="${OS} `oslevel` (`oslevel -r`)"
        elif [ "${OS}" = "Linux" ] ; then
            if [ -f /etc/redhat-release ] ; then
                DistroBasedOn='RedHat'
                DIST=`cat /etc/redhat-release |sed s/\ release.*//`
                PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
                REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
            elif [ -f /etc/SuSE-release ] ; then
                DistroBasedOn='SuSe'
                PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
                REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
            elif [ -f /etc/mandrake-release ] ; then
                DistroBasedOn='Mandrake'
                PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
                REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
            elif [ -f /etc/debian_version ] ; then
                DistroBasedOn='Debian'
                DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
                PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
                REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
            fi
            if [ -f /etc/UnitedLinux-release ] ; then
                DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
            fi
            OS=`lowercase $OS`
            DistroBasedOn=`lowercase $DistroBasedOn`
            readonly OS
            readonly DIST
            readonly DistroBasedOn
            readonly PSUEDONAME
            readonly REV
            readonly KERNEL
            readonly MACH
        fi

    fi
    echo "$DistroBasedOn"
}

ismac(){
    if [ `os_name` != "mac" ]; then return 1; fi
}

pkg-install(){
    osid=`os_name`
    case $osid in
        debian) $sudo_str apt-get -y install $1;;
        redhat) $sudo_str yum -y install $1;;
        mac)    brew install $1;;
        arch)   $sudo_str pacman -S --noconfirm $1;;
        *) echo os unknown;;
    esac
}

check_tool(){
    TOOL=$1
    sleep 0.1
    if ! has "$TOOL"; then
        echo "$TOOL not found"
        #if yn "install $TOOL now?"; then
            pkg-install $TOOL
        #fi
    fi
}

check_brew(){
    if ! has "brew"; then
        echo "brew not found"
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
}

check_mac_tool(){
    check_brew
    check_tool pkg-config
    check_tool automake
    check_tool Libtool
}
