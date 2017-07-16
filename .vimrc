" Basics
" ######
" Stuff you might expect to find in here, like indentation, is handled by
" .editorconfig

" Not vi compatible
set nocompatible

" Don't beep, blink
set visualbell

" Assume we've got a fast terminal connection lol 
set ttyfast

" Show line numbers
set number

" Show matching brackets when cursor is over
set showmatch

" No wrapping
set nowrap

" We don't need not steenking backup
set nobackup
set nowb
set noswapfile

" Take me to your leader
let mapleader = ","

" Auto indent and be smart about it
set autoindent
set smartindent

" Search
" ######

" incremental search
set incsearch

" highlight search terms
set hlsearch

" Ignore case and be smart about it
set ignorecase
set smartcase

" Clear search
map <leader><space> :let @/=''<cr> 

" Plugins
" #######
" Installed plugins:
" https://github.com/tpope/vim-surround.git

" Helps plugins load better, turn it back on later
filetype off

" DO PLUGIN STUFF HERE
" ---------------------
" Airline
" this isn't strictly an airline thing but cuts down on the redundancy
set noshowmode
set noruler
set laststatus=0

" ---------------------
" END PLUGIN STUFF HERE

" Turn syntax highlighting on
syntax on

" Plugins loaded, filetypes back on!
filetype plugin indent on

" Make vim pretty!
if (has("termguicolors"))
  set termguicolors
endif
colorscheme oceanic-next
let g:airline_theme='oceanicnext'
