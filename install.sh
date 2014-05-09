#!/bin/bash

set -e

APP_NAME=svm

has() {
  type "$1" > /dev/null 2>&1
  return $?
}

if [ -z "$XVM_DIR" ]; then
  XVM_DIR="$HOME/.$APP_NAME"
fi
if [ -z "$XVM_SRC_DIR" ]; then
  XVM_SRC_DIR="$XVM_DIR/src/svm"
fi

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

install_from_git() {
  if [ -z "$XVM_SOURCE" ]; then
    XVM_SOURCE="https://github.com/yarec/svm.git"
  fi

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

install_as_script() {
  if [ -z "$XVM_SOURCE" ]; then
    XVM_SOURCE="https://raw.github.com/creationix/nvm/master/nvm.sh"
  fi

  # Downloading to $XVM_DIR
  mkdir -p "$XVM_DIR"
  if [ -d "$XVM_DIR/nvm.sh" ]; then
    echo "=> $APP_NAME is already installed in $XVM_DIR, trying to update"
  else
    echo "=> Downloading $APP_NAME as script to '$XVM_DIR'"
  fi
  curl -s "$XVM_SOURCE" -o "$XVM_DIR/nvm.sh" || {
    echo >&2 "Failed to download '$XVM_SOURCE'.."
    return 1
  }
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
        ./configure && make install
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
        ./configure && make install
}

check_tool(){
    TOOL=$1
    sleep 0.1
    if ! has "$TOOL"; then
        echo "$TOOL not found"
        #if yn "install $TOOL now?"; then
            yum -y install $TOOL
        #fi
    fi
}

check_scsh(){
    if ! has "scsh"; then
        if ! has "scheme48"; then
            ins_s48
        fi
        ins_scsh
    fi
}

check_env(){
    for TOOL in git gcc autoconf; do
        check_tool $TOOL
    done
}

check_env
check_scsh

if [ -z "$METHOD" ]; then
  # Autodetect install method
  if has "git"; then
    install_from_git
  elif has "curl"; then
    echo install_as_script
  else
    echo >&2 "You need git, curl or wget to install $APP_NAME"
    exit 1
  fi
else
  if [ "$METHOD" = "git" ]; then
    if ! has "git"; then
      echo >&2 "You need git to install $APP_NAME"
      exit 1
    fi
    install_from_git
  fi
  if [ "$METHOD" = "script" ]; then
    if ! has "curl"; then
      echo >&2 "You need curl or wget to install $APP_NAME"
      exit 1
    fi
    echo install_as_script
  fi
fi

echo

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

BINPATH="\$HOME/.$APP_NAME/bin"
if [ -d /upg/svm ]; then BINPATH=/upg/svm/bin; fi

SOURCE_STR="export PATH="\$PATH:$BINPATH" # Add $APP_NAME to PATH for scripting"

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

