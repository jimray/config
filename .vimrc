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

" ...but undo history surviving a close is worth keeping. With no swap and no
" backup, quitting a file used to throw away every undo step with it.
" Now `u` still works after reopening.
if has('persistent_undo')
  " nvim already defaults to a sensible per-user undodir (:h undodir), and
  " its undo files aren't interchangeable with vim's, so let it use its own
  if !has('nvim')
    if !isdirectory($HOME . '/.vim/undo')
      call mkdir($HOME . '/.vim/undo', 'p', 0700)
    endif
    set undodir=~/.vim/undo//
  endif
  set undofile
endif

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

" Keep a few lines of context visible above/below the cursor
set scrolloff=3
set sidescrolloff=5

" Better command-line completion: show the menu, complete to the longest
" common prefix first, then cycle
set wildmenu
set wildmode=longest:full,full
set wildignore+=*/node_modules/*,*/.git/*,*/dist/*,*.o,*.pyc

" gitgutter draws in the sign column. Pinning it open stops the whole buffer
" from shifting left and right every time a line's git status changes.
if has('patch-8.1.1564') || has('nvim')
  set signcolumn=yes
endif

" Live preview of :s///  as you type it (nvim only)
if has('nvim')
  set inccommand=nosplit
endif

" Yank to / put from the system clipboard on demand. Deliberately NOT
" `set clipboard=unnamedplus` -- that routes every yank through a clipboard
" provider, which doesn't exist in a headless Lima VM.
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y "+y$
nnoremap <leader>p "+p
vnoremap <leader>p "+p

" Buffers
set hidden
" [b / ]b to navigate buffers, ,x to close current buffer
nnoremap [b :bprev<CR>
nnoremap ]b :bnext<CR>
nnoremap <leader>x :bd<CR>

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

" fzf.vim
" Better searching when opening a file
" ,f to search filenames in the working dir using fzf
" ,b to search buffers with fzf
" ,r to search within files using ripgrep
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>r :Rg<CR>

" ---------------------
" END PLUGIN STUFF HERE

" Make quitting work like most apps: if there's a buffer open
" Write (if modified) and close buffer, or quit if it's the last one
function! SmartQuit()
  if &modified
    if expand('%') == ''
      " No filename - prompt rather than silently fail
      echohl WarningMsg
      echo "No filename. Use :w <filename> to save first."
      echohl None
      return
    endif
    write
  endif
  if len(getbufinfo({'buflisted': 1})) > 1
    bdelete
  else
    quit
  endif
endfunction

function! SmartForceQuit()
  if len(getbufinfo({'buflisted': 1})) > 1
    bdelete!
  else
    quit!
  endif
endfunction


" Route :q / :q! / :wq / :x through the Smart* functions above.
"
" This used to be done with cnoreabbrev, which had two problems:
"
"   1. Abbreviations expand on ANY word boundary, not just at the start of a
"      command. `:Rg q` searched for "call SmartQuit()" instead of "q".
"   2. Typing :q! expanded the `q` as soon as the `!` was typed, producing
"      `:call SmartQuit()!` -- so :q! WROTE the file (the opposite of what
"      you asked for) and then failed with E488: Trailing characters.
"
" Checking the finished command line at <CR> time sidesteps both. Anything
" that isn't an exact match is passed straight through untouched.
"
" Escape hatch: :qa, :qa!, :wqa, and :wq! are not intercepted and still do
" the normal vim thing.
function! s:SmartQuitCR() abort
  if getcmdtype() !=# ':'
    return "\<CR>"
  endif
  let l:cmd = getcmdline()
  if l:cmd ==# 'q' || l:cmd ==# 'wq' || l:cmd ==# 'x'
    return "\<C-u>call SmartQuit()\<CR>"
  elseif l:cmd ==# 'q!'
    return "\<C-u>call SmartForceQuit()\<CR>"
  endif
  return "\<CR>"
endfunction

cnoremap <expr> <CR> <SID>SmartQuitCR()

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
