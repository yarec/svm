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

os_name(){
    OS=`lowercase \`uname\``
    KERNEL=`uname -r`
    MACH=`uname -m`

    if [ "{$OS}" == "windowsnt" ]; then
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

pkg-install(){
    case `os_name` in
        debian) $sudo_str apt-get -y install $1;;
        redhat) $sudo_str yum -y install $1;;
        mac)    brew install $1;;
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
git_clone(){
    REPO=$1
    DIR=$2
    SOURCE=$3
    # Cloning to $XVM_DIR
    echo "=> Downloading $REPO from git to '$DIR'"
    echo -e "\r=> \c"
    mkdir -p "$DIR"
    git clone "$SOURCE" "$DIR"
}

ins_scsh(){
    SCSH_TMP_DIR=$HOME/.svm/src/scsh
    SCSH_SOURCE="https://gitcafe.com/yarec/scsh"
    if [ ! -d "$SCSH_TMP_DIR/.git" ]; then
        git_clone "scsh" $SCSH_TMP_DIR $SCSH_SOURCE
    fi
    cd "$SCSH_TMP_DIR" && \
        git submodule update --init && \
        autoreconf && \
        ./configure && $sudo_str make install
}

#deps git gcc autoconf
ins_s48(){
    S48_TMP_DIR=$HOME/.svm/src/s48
    S48_SOURCE="https://github.com/yarec/s48"
    #git_clone "s48" $S48_TMP_DIR $S48_SOURCE

    S48_TMP_DIR="$HOME/.svm/archives/scheme48-1.9.2"
    #S48_TMP_DIR="s48"
    S48_SOURCE="https://gitcafe.com/yarec/s48/raw/master/scheme48-1.9.2.tgz"
    S48_TAR=$HOME/.svm/archives/s48-1.9.2.tar.gz
    S48_ARCHIVES_DIR=$HOME/.svm/archives
    if [ ! -f "$S48_TAR" ]; then
        mkdir -p $S48_ARCHIVES_DIR
        curl -kL $S48_SOURCE -o $S48_TAR || {
            echo >&2 "Failed to download '$S48_SOURCE'.."
            return 1
        }
    fi
    tar xvf $S48_TAR -C $S48_ARCHIVES_DIR

    cd "$S48_TMP_DIR" && \
        ./configure && $sudo_str make install
}

check_scsh(){
    if ! has "scsh"; then
        if ! has "scheme48"; then
            ins_s48
        fi
        ins_scsh
    fi
}

set -e

APP_NAME=svm
XVM_DIR="$HOME/.$APP_NAME"
XVM_SRC_DIR="$XVM_DIR/src/svm"
XVM_SOURCE="https://github.com/yarec/svm.git"

install_from_git() {
  if [ -d "$XVM_SRC_DIR/.git" ]; then
    echo "=> $APP_NAME is already installed in $XVM_SRC_DIR, trying to update"
    echo -e "\r=> \c"
    cd "$XVM_SRC_DIR" && git pull 2> /dev/null || {
      echo >&2 "Failed to update $APP_NAME, run 'git pull' in $XVM_SRC_DIR yourself.."
    }
  else
    git_clone $APP_NAME $XVM_SRC_DIR $XVM_SOURCE
  fi
}

## MAIN ##

for TOOL in git gcc autoconf; do
    check_tool $TOOL
done
check_mac_tool
check_scsh

BINPATH="\$HOME/.$APP_NAME/src/svm/bin"
if [ -d /upg/svm ]; then 
    BINPATH=/upg/svm/bin; 
else
    install_from_git
fi
mkdir -p $XVM_DIR/conf
cp $XVM_SRC_DIR/scheme/svm-conf.scm $XVM_DIR/conf/


# Detect profile file if not specified as environment variable (eg: PROFILE=~/.myprofile).
if [ -z "$PROFILE" ]; then
  if [ -f "$HOME/.zshrc" ]; then
    PROFILE="$HOME/.zshrc"
  elif [ -f "$HOME/.bash_profile" ]; then
    PROFILE="$HOME/.bash_profile"
  elif [ -f "$HOME/.profile" ]; then
    PROFILE="$HOME/.profile"
  fi
fi

SOURCE_STR="export PATH="$BINPATH:\$PATH" # Add $APP_NAME to PATH for scripting"

if [ -z "$PROFILE" ] || [ ! -f "$PROFILE" ] ; then
  if [ -z $PROFILE ]; then
    echo "=> Profile not found. Tried ~/.bash_profile ~/.zshrc and ~/.profile."
    echo "=> Create one of them and run this script again"
  else
    echo "=> Profile $PROFILE not found"
    echo "=> Create it (touch $PROFILE) and run this script again"
  fi
  echo "   OR"
  echo "=> Append the following line to the correct file yourself:"
  echo
  echo "   $SOURCE_STR"
  echo
else
  if ! grep -qc $APP_NAME'/bin' $PROFILE; then
    echo "=> Appending source string to $PROFILE"
    echo "" >> "$PROFILE"
    echo $SOURCE_STR >> "$PROFILE"
  else
    echo "=> Source string already in $PROFILE"
  fi
fi

echo "=> Close and reopen your terminal to start using $APP_NAME"

