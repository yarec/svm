
ins_scsh(){
    SCSH_TMP_DIR=$HOME/.svm/src/scsh
    SCSH_SOURCE="https://e.coding.net/ear/scsh.git"
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
    S48_SOURCE="https://e.coding.net/ear/s48.git"
    if [ ! -d "$S48_TMP_DIR/.git" ]; then
        git_clone "s48" $S48_TMP_DIR $S48_SOURCE
    fi

    S48_TAR=$S48_TMP_DIR/scheme48-1.9.2.tgz
    S48_TAR_DIR=$S48_TMP_DIR/scheme48-1.9.2
    cd $S48_TMP_DIR && tar xvf $S48_TAR

    cd "$S48_TAR_DIR" && \
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
