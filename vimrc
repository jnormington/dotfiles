set nocompatible
filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Bundle 'bling/vim-airline'
Bundle 'chriskempson/base16-vim'

" Splithandler
Bundle 'blarghmatey/split-expander'

" play nice with iterm2
Bundle 'sjl/vitality.vim'

" Git stuff
Bundle 'tpope/vim-fugitive'
Bundle 'airblade/vim-gitgutter'

" Ruby/Rails stuff
Bundle "tpope/vim-rails"
Bundle "vim-ruby/vim-ruby"
Bundle 'tpope/vim-bundler'

" Automatic end statements
Bundle 'tpope/vim-endwise'

" Go support
Bundle 'fatih/vim-go'

" Comment lines quickly
Bundle 'vim-scripts/tComment'

" Easy find like sublime
Bundle 'kien/ctrlp.vim'
Bundle 'scrooloose/nerdtree'

" Syntax error reporter
Bundle "scrooloose/syntastic"

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

set autowrite     " Automatically :write before running commands
set tabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smartindent
set nowrap

set nobackup
set nowritebackup
set noswapfile

set incsearch     " do incremental searching
set laststatus=2  " Always display the status line
set backspace=2   " Backspace deletes like most programs in insert mode

set relativenumber
set number
set numberwidth=2

set splitbelow
set splitright
set nocursorline "Fix slowness with really long lines

syntax on

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

inoremap jk <esc>

" Theme stuff
colorscheme base16-default-dark

" Highlight only the lines that pass 80 chars virtually (Damian Conway talk)
highlight ColorColumn ctermbg=blue
call matchadd('ColorColumn', '\%81v', 100)

augroup vimrcEx
  autocmd!

  autocmd! WinLeave * set nocursorline
  autocmd! WinEnter * set cursorline

  " .md is markdown - so syntax highlight and spellcheck
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufRead,BufNewFile *.md setlocal spell

  " Golang is tabbed not spaced
  autocmd BufNewFile,BufRead *.go setlocal shiftwidth=4 tabstop=4 softtabstop=4 noexpandtab
augroup END

" Remove all whitespace on the end of lines on write
autocmd BufWritePre *.* :%s/\s\+$//e

" Display that extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Key to insert mode with paste
map <Leader>i :set paste<CR>i
" Leave paste mode on exit
au InsertLeave * set nopaste

" Pretty print json
map <Leader>f :FormatJSON<CR>

" Quick commands for formatting serialized data
command! FormatJSON :%!python -m json.tool
command! FormatYAML :%!ruby -ryaml -e 'puts YAML.load(STDIN.read).to_yaml'
command! FormatXML :%!xmllint --format -
command! ConvertJSON2YAML :%!ruby -ryaml -rjson -e 'puts JSON.parse(STDIN.read).to_yaml'
command! ConvertYAML2JSON :%!ruby -ryaml -rjson -e 'puts YAML.load(STDIN.read).to_json'

" Copy to system clipboard (requires vim clipboard support)
:vnoremap Y "+y<CR>

" vim-go stuff
let g:go_fmt_command = "goimports"
let g:syntastic_go_checkers = ['go', 'golint']
let g:go_highlight_structs = 1
let g:go_highlight_functions = 1
