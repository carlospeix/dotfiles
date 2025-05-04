set nocompatible " We're running Vim, not Vi!
set hidden
set mouse=a
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set clipboard=unnamedplus

filetype off     " required

colorscheme default-light
set background=dark

set number relativenumber
set laststatus=2
set statusline+=%F
set path=.,,**
set wildmenu

" Search, hlserach, etc
set hlsearch
set incsearch

"set signcolumn=number
