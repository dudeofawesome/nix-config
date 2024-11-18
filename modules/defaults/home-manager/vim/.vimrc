set nocompatible

filetype off " required

" set shell to bash for compatibility with fish
set shell=/bin/bash

if isdirectory("~/.vim/bundle")
  " set the runtime path to include Vundle and initialize
  set rtp+=~/.vim/bundle/Vundle.vim
  call vundle#begin()
  " let Vundle manage Vundle, required
  Plugin 'VundleVim/Vundle.vim'
  Plugin 'NLKNguyen/papercolor-theme'
  Plugin 'bling/vim-airline'
  Plugin 'rizzatti/dash.vim'
  Plugin 'scrooloose/nerdtree'
  Plugin 'kien/rainbow_parentheses.vim'
  Plugin 'prettier/vim-prettier'
  Plugin 'vimpostor/vim-lumen'
  Plugin 'editorconfig/editorconfig-vim'
  call vundle#end()            " required
  filetype plugin indent on    " required
endif

" Keymaps
:imap jj <Esc>

" Redo with U instead of Ctrl+R
nnoremap U <C-R>

" Enable mouse
set mouse=a

let mapleader=","
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

set hidden
set nowrap               " don't wrap lines
set tabstop=2            " a tab is four spaces
set expandtab            " Insert spaces instead of a tab
set backspace=indent,eol,start
                         " allow backspacing over everything in insert mode
set autoindent           " always set autoindenting on
set copyindent           " copy the previous indentation on autoindenting
set number               " always show line numbers
set relativenumber
                         " use relative line numbers to improve movement speed
set shiftwidth=2         " number of spaces to use for autoindenting
set shiftround           " use multiple of shiftwidth when indenting with '<' and '>'
set showmatch            " set show matching parenthesis
set ignorecase           " ignore case when searching
set smartcase            " ignore case if search pattern is all lowercase,
                         "    case-sensitive otherwise
set smarttab             " insert tabs on the start of a line according to
                         "    shiftwidth, not tabstop
set hlsearch             " highlight search terms
set incsearch            " show search matches as you type

set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
set wildignore=*.swp,*.bak,*.pyc,*.class
set title                " change the terminal's title
set visualbell           " don't beep
set noerrorbells         " don't beep

set nobackup
set noswapfile

set ballooneval
autocmd FileType typescript setlocal balloonexpr=tsuquyomi#balloonexpr()

filetype plugin indent on

autocmd filetype python set expandtab

" enable prettier formatting
let g:prettier#autoformat_config_present = 1
let g:prettier#autoformat_require_pragma = 0

set t_Co=256
syntax enable
let g:lumen_startup_overwrite = 1 " get system's light/dark state
try
  colorscheme PaperColor " load theme
catch
  " Couldn't load colorscheme
endtry

let g:airline_powerline_fonts = 1
set laststatus=2

let g:netrw_liststyle = 3
