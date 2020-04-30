" Basics
" ######
" Stuff you might expect to find in here, like indentation, is handled by
" .editorconfig

" Not vi compatible
set nocompatible

" Don't beep, blink
set visualbell

" Assume we've got a fast terminal connection
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

" Comma leader
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

" unset the last search pattern when hitting return
nnoremap <CR> :noh<CR><CR>

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Plugins
" #######

" Helps plugins load better, turn it back on later
filetype off

" DO PLUGIN STUFF HERE
" ---------------------
" Airline
" this isn't strictly an airline thing but cuts down on the redundancy
set noshowmode
set noruler
set laststatus=0

" sensible markdown folding via vim-markdown
let g:vim_markdown_folding_style_pythonic = 1
" don't autofold section headers
let g:vim_markdown_folding_level = 6

" make vim work like a normal text editor for prose writing
augroup pencil
  autocmd!
  autocmd FileType markdown,mkd call pencil#init()
  autocmd FileType text         call pencil#init()
augroup END

" ---------------------
" END PLUGIN STUFF HERE

" Turn syntax highlighting on
syntax enable

" Plugins loaded, filetypes back on!
filetype plugin indent on

" Split smarter
set splitbelow
set splitright

" Make vim pretty
set t_Co=256
if (has("termguicolors"))
  set termguicolors
endif
colorscheme oceanic-next
let g:airline_theme='oceanicnext'
