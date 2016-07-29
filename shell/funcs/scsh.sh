
ins_scsh(){
    SCSH_TMP_DIR=$HOME/.svm/src/scsh
    SCSH_SOURCE="https://git.coding.net/softidy/scsh.git"
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
    S48_SOURCE="https://coding.net/u/softidy/p/s48/git/raw/master/scheme48-1.9.2.tgz"
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
