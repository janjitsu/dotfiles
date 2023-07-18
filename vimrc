" ################################## VUNDLE ####################################

filetype off                  " required

"""" PLUG
call plug#begin('~/.vim/plugged')

" my plugins
Plug 'AndrewRadev/linediff.vim'
Plug 'ConradIrwin/vim-bracketed-paste'
Plug 'SirVer/ultisnips'
Plug 'bling/vim-airline'
Plug 'christoomey/vim-tmux-navigator'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'etdev/vim-hexcolor'
Plug 'fatih/vim-go', {'do': ':GoUpdateBinaries' }
Plug 'hashivim/vim-terraform'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'kchmck/vim-coffee-script'
Plug 'leafgarland/typescript-vim'
Plug 'mattn/emmet-vim'
Plug 'mileszs/ack.vim'
Plug 'othree/xml.vim'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'sickill/vim-monokai'
Plug 'slim-template/vim-slim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-markdown'
Plug 'udalov/kotlin-vim'
Plug 'vinhnx/Ciapre.tmTheme'
Plug 'xolox/vim-lua-ftplugin'
Plug 'xolox/vim-misc'
Plug 'neoclide/coc.nvim', { 'branch': 'release', 'do': ':CocInstall coc-go coc-phpls coc-tsserver' }
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'arnaud-lb/vim-php-namespace' "run this: ctags -R --PHP-kinds=cfi
Plug 'ludovicchabant/vim-gutentags'
Plug 'StanAngeloff/php.vim'
Plug 'stephpy/vim-php-cs-fixer'
Plug 'roxma/nvim-yarp'
Plug 'tpope/vim-commentary'
Plug 'adoy/vim-php-refactoring-toolbox'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'ap/vim-css-color'


call plug#end()            " required

filetype plugin indent on  " required
" To update vundle run:
" on vim :PluginInstall
" on bash $vim +PluginInstall +qall

" ################################## MISC ######################################

" Colorscheme
syntax on
set background=dark
colorscheme monokai

" misc configs
set nocompatible   " vi's compatible mode is off
set encoding=UTF-8 " set default encoding
set autoindent     " makes indenting a little easier
set hidden         " don't close unsaved files on buffers
set visualbell     " disable beeps
set cmdheight=2    " better display for commands
set updatetime=300 " Faster update time for cursor
set shortmess+=c   " short completion messages
set signcolumn=yes " always show sign columns
set modelines=0    " don't use variable lines
set backspace=indent,eol,start    " backspace will delete control characters

" ############################### INDENTATION ##################################

" default tabstop to 4 spaces, use specific tabing for filetype
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
autocmd Filetype ruby setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd Filetype yaml setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd Filetype eruby setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd Filetype phtml setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
autocmd Filetype html setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
autocmd Filetype php setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
autocmd Filetype python setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
autocmd Filetype json setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd Filetype javascript setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd Filetype javascriptreact setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab

" text wrapping
set wrap
set textwidth=79
set formatoptions=qrnl
set colorcolumn=81

" folding
set nofoldenable " start with no folds
autocmd Filetype html setlocal foldmethod=indent fdl=3
autocmd Filetype php setlocal foldmethod=indent fdl=3

" ############################### STATUS BAR ###################################

set laststatus=2   " always display status line
set showmode       " show what's the current mode (insert, normal, visual)
set ruler          " show current column and lines on statusbar
set showcmd        " show commands while they're typed on bottom right
" show how far away a line is from current line, useful for d<NUMBER>d'
autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber

" ######################### SAVING AND BACKUPING ###############################

" keep an undo tree on a separate file
set undofile
set backup                        " enable backups
set noswapfile                    " it's 2013, Vim.

set undodir=~/.vim/tmp/undo//     " undo files
set backupdir=~/.vim/tmp/backup// " backups
set directory=~/.vim/tmp/swap//     " swap files

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

" remove trailing whitespaces on save
autocmd BufWritePre * :%s/\s\+$//e

" ######################## SEARCHING and REPLACING #############################

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

" reselect just pasted text
nnoremap <leader>v V`]
" quick vimrc lookup
nnoremap <leader>ev :tabnew ~/.vimrc<CR>
" quick vimrc reload
nnoremap <leader>rv :so $MYVIMRC<CR>
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
" Reload file with <leader>F5
autocmd VimEnter * imap <leader><F5> :checktime<CR>a
autocmd VimEnter * nmap <leader><F5> :checktime<CR>
" Only Window to new tab
nnoremap <C-w>o :tab sp<CR>
" Easy copy to clipboard
noremap <Leader>y "+y
noremap <Leader>p "+p


" ############################ PLUGIN SPECIFIC #################################

"""" NERDTree
let NERDTreeQuitOnOpen=0
let NERDTreeWinSize=35
autocmd VimEnter * nmap <F3> :NERDTreeToggle<CR>
autocmd VimEnter * imap <F3> <Esc>:NERDTreeToggle<CR>a
autocmd VimEnter * nmap <F4> :NERDTreeFind<CR>

"""" Emmet
let g:user_emmet_leader_key=','

"""" Syntastic @TODO REMOVE THIS
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 1
let g:syntastic_php_checkers = ['php']

"""" Golang
let g:go_bin_path = "/home/janjitsu/.go/bin"
let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']
let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go', 'php'] }
let g:go_list_type = "quickfix"
let g:go_fmt_command = "goimports"
autocmd BufWritePre *.go <Plug>(go-build)
autocmd FileType go nmap <leader>b <Plug>(go-build)
autocmd FileType go nmap <leader>r <Plug>(go-run)

"""" js
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_eslint_exe = 'eslint -c ~/dotfiles/eslintrc.js'

"""" Highlight unwanted trailing spaces
highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

"""" EditorConfig please don't mess with fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

"""" coc.vim
" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

let g:coc_disable_startup_warning = 1

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges. ** NOT USING RIGHT NOW
" Requires 'textDocument/selectionRange' support of language server.
" nmap <silent> <C-s> <Plug>(coc-range-select)
" xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline+=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

let g:go_def_mapping_enabled = 0

"""" ctrlp.vim
set runtimepath^=~/.vim/bundle/ctrlp.vim
nnoremap <leader>f :CtrlPMRU<CR>
nnoremap <leader>p :CtrlPMixed<CR>

"""" Ultsnips
"""" use :UltiSnipsEditSplit to customize
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/UltiSnips']

"""" Vim-markdown
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh']


"""" vim-php-namespace
function! IPhpInsertUse()
    call PhpInsertUse()
    call feedkeys('a',  'n')
endfunction
autocmd FileType php inoremap <leader>u <Esc>:call IPhpInsertUse()<CR>
autocmd FileType php noremap <leader>u :call PhpInsertUse()<CR>

function! IPhpExpandClass()
    call PhpExpandClass()
    call feedkeys('a', 'n')
endfunction
autocmd FileType php inoremap <leader>e <Esc>:call IPhpExpandClass()<CR>
autocmd FileType php noremap <leader>e :call PhpExpandClass()<CR>

"""" php.vim
let g:php_version_id = 80002
syn match phpParentOnly "[()]" contained containedin=phpParent
hi phpParentOnly guifg=#f08080 guibg=NONE gui=NONE


"""" php-cs-fixer
let g:php_cs_fixer_level = "symfony"                   " options: --level (default:symfony)
let g:php_cs_fixer_config = "default"                  " options: --config
let g:php_cs_fixer_rules = "@PSR2"          " options: --rules (default:@PSR2)
let g:php_cs_fixer_php_path = "php"               " Path to PHP
let g:php_cs_fixer_enable_default_mapping = 1     " Enable the mapping by default (<leader>pcd)
let g:php_cs_fixer_dry_run = 0                    " Call command with dry-run option
let g:php_cs_fixer_verbose = 0                    " Return the output of command if

autocmd BufWritePost *.php silent! call PhpCsFixerFixFile()

"""" guttentags
set statusline+=%{gutentags#statusline()}

