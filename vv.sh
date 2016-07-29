export BASE_PATH=~/.vim/myvimrc
export VIMRT=~/.vim/myvimrc/vimfiles
export VUNDLE=true
git clone git://github.com/amix/vimrc.git ~/.vim/amix-vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
git clone https://github.com/yarec/vimrc ~/.vim/myvimrc
mkdir -p ~/.vim/tmp
run vim: vim -u ~/.vim/myvimrc
