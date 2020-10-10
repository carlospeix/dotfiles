set nocompatible " We're running Vim, not Vi!
set hidden
set mouse=a
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent

filetype off     " required

" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'vim-ruby/vim-ruby'
Plugin 'w0rp/ale'

Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

syntax on          " Enable syntax highlighting
filetype on        " Enable filetype detection
filetype indent on " Enable filetype-specific indenting
filetype plugin on " Enable filetype-specific plugins

colorscheme default-light
set background=dark

set number relativenumber
set laststatus=2
set statusline+=%F
set path=.,,**
set wildmenu

" netrw configuration
let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_winsize = 30
"let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+,\(^\|\s\s\)ntuser\.\S\+'
autocmd FileType netrw set nolist

" Search, hlserach, etc
set hlsearch
set incsearch

