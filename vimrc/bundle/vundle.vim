" ----------------------------------------
" Vundle
" ----------------------------------------

set nocompatible
filetype off     " required!

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
"Bundle 'gmarik/vundle'
Plugin 'VundleVim/Vundle.vim'

" ---------------
" Plugin Bundles
" ---------------

"" Navigation
Plugin 'ZoomWin'
Plugin 'taglist-plus'

"Bundle 'wincent/Command-T'
"" This fork is required due to remapping ; to :
Plugin 'christoomey/vim-space'
Plugin 'Lokaltog/vim-easymotion'
"Bundle 'mutewinter/LustyJuggler'
Plugin 'kien/ctrlp.vim'
"" UI Additions
Plugin 'nathanaelkane/vim-indent-guides'
let g:indent_guides_guide_size = 1

Plugin 'Lokaltog/vim-powerline'
Plugin 'scrooloose/nerdtree'
Plugin 'Rykka/colorv.vim'
"Bundle 'nanotech/jellybeans.vim'
Plugin 'tomtom/quickfixsigns_vim'
"" Commands
Plugin 'scrooloose/nerdcommenter'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-speeddating'
"Bundle 'tpope/vim-fugitive'
Plugin 'godlygeek/tabular'
Plugin 'mileszs/ack.vim'
"Bundle 'gmarik/sudo-gui.vim'
"Bundle 'milkypostman/vim-togglelist'
"Bundle 'mutewinter/swap-parameters'
"Bundle 'keepcase.vim'
"Bundle 'scratch.vim'
Plugin 'mattn/emmet-vim'
"" Automatic Helpers
Plugin 'IndexedSearch'
"Bundle 'xolox/vim-session'
Plugin 'Raimondi/delimitMate'
Plugin 'scrooloose/syntastic'
Plugin 'ervandew/supertab'
Plugin 'gregsexton/MatchTag'
Plugin 'Shougo/neocomplcache'
let g:neocomplcache_enable_at_startup = 1

"" Snippets
Plugin 'garbas/vim-snipmate'
Plugin 'scrooloose/snipmate-snippets'
Plugin 'MarcWeber/vim-addon-mw-utils'
" FuzzyFinder
Plugin 'FuzzyFinder'

"
"" Language Additions
"Bundle 'spf13/PIV'

""   Ruby
"Bundle 'vim-ruby/vim-ruby'
"Bundle 'tpope/vim-haml'
"Bundle 'tpope/vim-rails'
"Bundle 'tpope/vim-rake'
""   JavaScript
"Bundle 'pangloss/vim-javascript'
"Bundle 'kchmck/vim-coffee-script'
"Bundle 'leshill/vim-json'
"Bundle 'itspriddle/vim-jquery'
"Bundle 'nono/vim-handlebars'
""   TomDoc
"Bundle 'mutewinter/tomdoc.vim'
"Bundle 'jc00ke/vim-tomdoc'
""   Other Languages
"Bundle 'msanders/cocoa.vim'
"Bundle 'mutewinter/taskpaper.vim'
"Bundle 'mutewinter/nginx.vim'
"Bundle 'timcharper/textile.vim'
"Bundle 'ChrisYip/Better-CSS-Syntax-for-Vim'
"Bundle 'acustodioo/vim-tmux'
Plugin 'hallison/vim-markdown'
"Bundle 'xhtml.vim--Grny'
"Bundle 'groenewege/vim-less'
"" MatchIt
"Bundle 'matchit.zip'
"Bundle 'kana/vim-textobj-user'
"Bundle 'nelstrom/vim-textobj-rubyblock'
"
"" Libraries
Plugin 'L9'
"Bundle 'tpope/vim-repeat'
Plugin 'tomtom/tlib_vim'
"Bundle 'mathml.vim'

" Automatically detect file types. (must turn on after Vundle)
call vundle#end()
filetype plugin indent on  

