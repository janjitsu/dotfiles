" ################################## VUNDLE ####################################
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" my plugins
Plugin 'mileszs/ack.vim'
Plugin 'wincent/command-t'
Plugin 'mattn/emmet-vim'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/syntastic'
Plugin 'eruby.vim'
Plugin 'ConradIrwin/vim-bracketed-paste'
Plugin 'kchmck/vim-coffee-script'
Plugin 'tpope/vim-fugitive'
Plugin 'sickill/vim-monokai'
Plugin 'bling/vim-airline'
Plugin 'jeffkreeftmeijer/vim-numbertoggle'
Plugin 'slim-template/vim-slim'
Plugin 'othree/xml.vim'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'editorconfig/editorconfig-vim'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Colorscheme
syntax on
set background=dark
colorscheme monokai

" misc configs
set nocompatible   " vi's compatible mode is off
set encoding=utf-8 " set default encoding
set autoindent     " makes indenting a little easier
set hidden         " don't close unsaved files on buffers
set visualbell     " disable beeps
set modelines=0    " don't use variable lines
set backspace=indent,eol,start " backspace will delete control characters

" ############################### INDENTATION ##################################
" default tabstop to 4 spaces, use specific tabing for filetype
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
autocmd Filetype ruby setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd Filetype eruby setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd Filetype html setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
autocmd Filetype php setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab

" text wrapping
set wrap
set textwidth=79
set formatoptions=qrnl
set colorcolumn=81

" folding
set nofoldenable " start with no folds
autocmd Filetype html setlocal foldmethod=indent fdl=3
autocmd Filetype php setlocal foldmethod=indent fdl=3

" code completion (not using it for now)
" set wildmenu               " show completion on status bar
" set wildmode=list:longest  " completionmode logenst string first
" Easy omnicompletion
"inoremap <C-Space> <C-x><C-o>
"inoremap <C-@> <C-Space>

" ############################### STATUS BAR ###################################
set laststatus=2   " always display status line
set showmode       " show what's the current mode (insert, normal, visual)
set ruler          " show current column and lines on statusbar
set showcmd        " show commands while they're typed on bottom right
" show how far away a line is from current line useful for d<NUMBER>d'
autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber

" ######################### SAVING AND BACKUPING ###############################
" keep an undo tree on a separate file
set undofile
set backup                        " enable backups
set noswapfile                    " it's 2013, Vim.

set undodir=~/.vim/tmp/undo//     " undo files
set backupdir=~/.vim/tmp/backup// " backups
set directory=~/.vim/tmp/swap//   " swap files

" Make those folders automatically if they don't already exist.
if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), " p" )
endif
if !isdirectory(expand(&backupdir))
    call mkdir(expand(&backupdir), " p" )
endif
if !isdirectory(expand(&directory))
    call mkdir(expand(&directory), " p" )
endif

" save on losing focus - is this really working?
au FocusLost * :wa

" ######################## SEARCHING and REPLACING #############################
" improve search
" use new regex syntax
nnoremap / /\v
vnoremap / /\v
" only ignore case if there's no Capital letter on search query
set ignorecase
set smartcase
" always substitute globally on line
set gdefault
" search highlighting
set incsearch
set showmatch
set hlsearch

" ############################## NAVIGATION ####################################
" movement by screenline instead of file line
nnoremap j gj
nnoremap k gk

set scrolloff=3    " trigger scroolling 3 lines above the last
set ttyfast        " faster scrolling

" easier window vsplit and motion
nnoremap <leader>w <C-w>v<C-w>l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l


" ########################### LEADER SHORTCUTS #################################
" change leader key (default is \)
let mapleader = ','

" use ack
nnoremap <leader>a :Ack
" reselect just pasted text
nnoremap <leader>v V`]
" quick vimrc lookup
nnoremap <leader>ev <C-w><C-v><C-l>:e $MYVIMRC<CR>
" easily clear search
nnoremap <leader><space> :noh<cr>

" ############################ MISC SHORTCUTS ##################################
" easily type commands
nnoremap ; :
" Save crt+s
noremap <C-S> :w<CR>
inoremap <C-S> <ESC>:w<CR>
" Quit ctrl+q
noremap <C-Q> :q<CR>
inoremap <C-Q> <ESC>:q<CR>

" ############################ PLUGIN SPECIFIC #################################

" NERDTree
let NERDTreeQuitOnOpen=0
let NERDTreeWinSize=35
autocmd VimEnter * nmap <F3> :NERDTreeToggle %<CR>
autocmd VimEnter * imap <F3> <Esc>:NERDTreeToggle<CR>a
autocmd VimEnter * nmap <F4> :NERDTreeFind<CR>

" Emmet
let g:user_emmet_leader_key=','

" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 1
let g:syntastic_php_checkers = ['php']

" highlight unwanted trailing spaces
highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

"editor config please don't mess with fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.*']
