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
fi

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

  if [ -d "$XVM_DIR/.git" ]; then
    echo "=> $APP_NAME is already installed in $XVM_DIR, trying to update"
    echo -e "\r=> \c"
    cd "$XVM_DIR" && git pull 2> /dev/null || {
      echo >&2 "Failed to update $APP_NAME, run 'git pull' in $XVM_DIR yourself.."
    }
  else
    git_clone $APP_NAME $XVM_DIR $XVM_SOURCE
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
    SCSH_TMP_DIR=.tmp_scsh_src
    SCSH_SOURCE="https://github.com/scheme/scsh"
    git_clone "scsh" $SCSH_TMP_DIR $SCSH_SOURCE
    cd "$SCSH_TMP_DIR" && \
        git submodule update --init && \
        autoreconf && \
        ./configure && make install
}

ins_s48(){
    S48_TMP_DIR=.tmp_s48_src
    S48_SOURCE="https://github.com/yarec/s48"
    #git_clone "s48" $S48_TMP_DIR $S48_SOURCE

    S48_TMP_DIR="scheme48-1.9.2"
    S48_SOURCE="http://s48.org/1.9.2/scheme48-1.9.2.tgz"
    S48_TAR="s48-1.9.2.tgz"
    curl -s $S48_SOURCE -o $S48_TAR || {
        echo >&2 "Failed to download '$XVM_SOURCE'.."
        return 1
    }
    tar xvf $S48_TAR
    cd "$S48_TMP_DIR" && \
        #./autogen.sh && \
        ./configure && make install
}

if has "scsh"; then
    echo "scsh ok"
else
    echo "scsh not found"
    if has "scheme48"; then
        echo "scheme48 ok"
    else
        ins_s48
        echo "scheme48 not found"
    fi
    ins_scsh
fi

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
  if [ -f "$HOME/.bash_profile" ]; then
    PROFILE="$HOME/.bash_profile"
  elif [ -f "$HOME/.zshrc" ]; then
    PROFILE="$HOME/.zshrc"
  elif [ -f "$HOME/.profile" ]; then
    PROFILE="$HOME/.profile"
  fi
fi

SOURCE_STR="[ -s \"$XVM_DIR/$APP_NAME.sj\" ] && . \"$XVM_DIR/$APP_NAME.sh\"  # This loads $APP_NAME"

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
  if ! grep -qc 'nvm.sh' $PROFILE; then
    echo "=> Appending source string to $PROFILE"
    echo "" >> "$PROFILE"
    echo $SOURCE_STR >> "$PROFILE"
  else
    echo "=> Source string already in $PROFILE"
  fi
fi

echo "=> Close and reopen your terminal to start using $APP_NAME"

