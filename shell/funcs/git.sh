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
