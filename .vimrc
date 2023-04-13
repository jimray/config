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

" Don't wait so long to do things
set updatetime=100

" Search
" ######

" incremental search
set incsearch

" highlight search terms
set hlsearch

" Ignore case and be smart about it
set ignorecase
set smartcase

" Clear search with a comma and space
map <leader><space> :let @/=''<cr>

" unset the last search pattern when hitting return
nnoremap <CR> :noh<CR><CR>

" Display extra whitespace
" This breaks lists in markdown
" TODO: only set for files that are not markdown
"set list listchars=tab:»·,trail:·,nbsp:·

" Split smarter
set splitbelow
set splitright

" Buffers
set hidden
" ctrl+n, ctrl+p to go back and forth between buffers
nnoremap <C-N> :bnext<CR>
nnoremap <C-P> :bprev<CR>
nnoremap <C-W> :bd<CR>

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
" enable tabline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

" sensible markdown folding via vim-markdown
let g:vim_markdown_folding_style_pythonic = 1
" don't autofold section headers
let g:vim_markdown_folding_level = 6

filetype plugin indent on

" vim-pencil
" make vim work like a normal text editor for prose writing
let g:pencil#wrapModeDefault = 'soft'

" vim-rooter
" some defaults as to what constitutes a project directory
let g:rooter_patterns = ['.git', 'Makefile']

augroup pencil
  autocmd!
  autocmd FileType markdown,mkd call pencil#init()
  autocmd FileType text         call pencil#init()

  " don't conceal markdown
  let g:pencil#conceallevel = 0
augroup END

" ---------------------
" END PLUGIN STUFF HERE

" Turn syntax highlighting on
syntax enable

" Plugins loaded, filetypes back on!

" Make vim pretty
set t_Co=256
if (has("termguicolors"))
  set termguicolors
endif

let g:oceanic_italic_comments = 1
let g:oceanic_transparent_bg = 1
colorscheme oceanicnext
