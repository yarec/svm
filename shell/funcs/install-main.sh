
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

for TOOL in git gcc autoconf make wget tar; do
    check_tool $TOOL
done
if ismac ; then
    check_mac_tool
fi
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

