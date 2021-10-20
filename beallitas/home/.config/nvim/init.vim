" vim-plug install nvim
"                  |
"                  |
"                  ˇ ez a vissza perjel nem kell a parancsba
"                  |
"                  |
"                  ˇ
" sh -c 'curl -fLo \"${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
"       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
"
" 
" archlinux: pacman -S python-neovim xsel python-jedi flake8 autopep8 git ctags pip
"
"
" Figure out the system Python for Neovim.
if exists("$VIRTUAL_ENV")
    let g:python3_host_prog=substitute(system("which -a python3 | head -n2 | tail -n1"), "\n", '', 'g')
else
    let g:python3_host_prog=substitute(system("which python3"), "\n", '', 'g')
endif


if has('win32') || has('win64')
  let g:plugged_home = '~/AppData/Local/nvim/plugged'
else
  let g:plugged_home = '~/.vim/plugged'
endif
" Plugins List
call plug#begin(g:plugged_home)
  " UI related
  Plug 'chriskempson/base16-vim'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  " Better Visual Guide
  Plug 'Yggdroot/indentLine'
  " syntax check
  "Plug 'w0rp/ale'
  Plug 'dense-analysis/ale'
  " Autocomplete
  Plug 'ncm2/ncm2'
  Plug 'roxma/nvim-yarp'
  Plug 'ncm2/ncm2-bufword'
  Plug 'ncm2/ncm2-path'
  Plug 'ncm2/ncm2-jedi'
  " Formater
  Plug 'Chiel92/vim-autoformat'
  " colorscheme
  Plug 'joshdick/onedark.vim'
  " Track the engine.
  Plug 'SirVer/ultisnips'
  Plug 'honza/vim-snippets'
  " runner
  Plug 'aben20807/vim-runner'
  " NerdTree
  Plug 'preservim/nerdtree'
  " git
  Plug 'tpope/vim-fugitive'
  " Go programming
  Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
  " undotree The undo history visualizer for VIM 
  Plug 'mbbill/undotree'
call plug#end()
filetype plugin indent on

" Configurations Part
" UI configuration
syntax on
syntax enable
" colorscheme
"let base16colorspace=256
"colorscheme base16-gruvbox-dark-hard
colorscheme onedark
set background=dark
" True Color Support if it's avaiable in terminal
if has("termguicolors")
    set termguicolors
endif
"if has("gui_running")
"  set guicursor=n-v-c-sm:block,i-ci-ve:block,r-cr-o:blocks
"endif

if has('gui_running')
    set guifont=Droid\ Sans\ Mono\ Slashed\ for\ Powerline
endif

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.dirty='⚡'


" spell languages
set spelllang=en,hu

nnoremap <silent><F10> :set spell!<cr>
inoremap <silent> <F10> <C-O>:set spell!<cr>


set number
"set relativenumber
set hidden
set mouse=a
set noshowmode
set noshowmatch
set nolazyredraw
" Turn off backup
set nobackup
set noswapfile
set nowritebackup
" Search configuration
set ignorecase                    " ignore case when searching
set smartcase                     " turn on smartcase
" Tab and Indent configuration
set expandtab
set tabstop=4
set shiftwidth=4
" print new line between brackets
inoremap {<CR> {<CR>}<Esc>ko
" vim-autoformat
noremap <F2> :Autoformat<CR>
" NCM2
augroup NCM2
  autocmd!
  " enable ncm2 for all buffers
  autocmd BufEnter * call ncm2#enable_for_buffer()
  " :help Ncm2PopupOpen for more information
  set completeopt=noinsert,menuone,noselect
  " When the <Enter> key is pressed while the popup menu is visible, it only
  " hides the menu. Use this mapping to close the menu and also start a new line.
  inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

  " Use <TAB> to select the popup menu:
  inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

  " uncomment this block if you use vimtex for LaTex
  " autocmd Filetype tex call ncm2#register_source({
  "           \ 'name': 'vimtex',
  "           \ 'priority': 8,
  "           \ 'scope': ['tex'],
  "           \ 'mark': 'tex',
  "           \ 'word_pattern': '\w+',
  "           \ 'complete_pattern': g:vimtex#re#ncm2,
  "           \ 'on_complete': ['ncm2#on_complete#omni', 'vimtex#complete#omnifunc'],
  "           \ })
augroup END
" Ale
let g:ale_lint_on_enter = 0
let g:ale_lint_on_text_changed = 'never'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_linters = {'python': ['flake8']}
" Airline
let g:airline_left_sep  = ''
let g:airline_right_sep = ''
let g:airline#extensions#ale#enabled = 1
let airline#extensions#ale#error_symbol = 'E:'
let airline#extensions#ale#warning_symbol = 'W:'

" Runner
" Use key mappings setting from this plugin by default.
let g:runner_use_default_mapping = 1

" Save file first before compile and run by default.
let g:runner_is_save_first = 1

" Print a timestamp on the top of output by default.
let g:runner_print_timestamp = 1

" Print time usage of do all actions by default.
let g:runner_print_time_usage = 1

" Show the comment information by default.
let g:runner_show_info = 1

" Not auto remove tmp file by default.
let g:runner_auto_remove_tmp = 0

" Use <F5> to compile and run code by default.
" Feel free to change mapping you like.
let g:runner_run_key = "<F5>"

" Set tmp dir for output.
let g:runner_tmp_dir = "/tmp/vim-runner/"

" Section: work with other plugins
" w0rp/ale
let g:runner_is_with_ale = 0
" iamcco/markdown-preview.vim
let g:runner_is_with_md = 0

" Section: executable settings
let g:runner_c_executable = "gcc"
let g:runner_cpp_executable = "g++"
let g:runner_rust_executable = "cargo"
let g:runner_python_executable = "python3"

" Section: compile options settings
let g:runner_c_compile_options = "-std=c11 -Wall"
let g:runner_cpp_compile_options = "-std=c++11 -Wall"
let g:runner_rust_compile_options = ""

" Section: run options settings
let g:runner_c_run_options = ""
let g:runner_cpp_run_options = ""
let g:runner_rust_run_backtrace = 1
let g:runner_rust_run_options = ""

" disable line too long warning flak8
let g:syntastic_python_flake8_args='--ignore=F821,E302,E501'

" NerdTree
map <F3> :NERDTreeToggle<CR>

"insert and remove comments in visual and normal mode
vmap ,ic :s/^/# /g<CR>:let @/ = ""<CR>
map ,ic :s/^/# /g<CR>:let @/ = ""<CR>
vmap ,rc :s/^# //g<CR>:let @/ = ""<CR>
map ,rc :s/^# //g<CR>:let @/ = ""<CR>

" undotree The undo history visualizer for VIM 
nnoremap <F6> :UndotreeToggle<CR>
" store the undo files in a seperate place like below
if has("persistent_undo")
    set undodir=$HOME/.vim/undodir"/.undodir"
    set undofile
endif
