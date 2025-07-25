set nocompatible
filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Bundle 'bling/vim-airline'
Bundle 'w0ng/vim-hybrid'

" Async linter/fixer/lsp
Bundle "w0rp/ale"

" Git stuff
Bundle 'tpope/vim-fugitive'
Bundle 'airblade/vim-gitgutter'

" Ruby/Rails stuff
Bundle "tpope/vim-rails"
Bundle "vim-ruby/vim-ruby"
Bundle 'tpope/vim-bundler'
Bundle 'slim-template/vim-slim'

" Automatic end statements
Bundle 'tpope/vim-endwise'

" Comment lines quickly
Bundle 'vim-scripts/tComment'

" Easy find like sublime
Bundle 'kien/ctrlp.vim'
Bundle 'scrooloose/nerdtree'

" Zeal docs
Bundle 'KabbAmine/zeavim.vim'

" Go support
Bundle 'fatih/vim-go'

" GraphQL
Bundle 'jparise/vim-graphql'

" Typescript
Bundle 'leafgarland/typescript-vim'
Bundle 'peitalin/vim-jsx-typescript'

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

" Theme stuff
set background=dark

let g:hybrid_custom_term_colors = 1
colorscheme hybrid

" Highlight only the lines that pass 80 chars virtually (Damian Conway talk)
highlight ColorColumn ctermbg=blue
call matchadd('ColorColumn', '\%81v', 100)

augroup vimrcEx
  autocmd!

  autocmd WinLeave * set nocursorline
  autocmd WinEnter * set cursorline

  " Remove all whitespace on the end of lines on write
  autocmd BufWritePre *.* :%s/\s\+$//e

  " .md is markdown - so syntax highlight and spellcheck
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufRead,BufNewFile *.md setlocal spell

  " Golang is tabbed not spaced
  autocmd BufNewFile,BufRead *.go setlocal shiftwidth=4 tabstop=4 softtabstop=4 noexpandtab
  autocmd BufNewFile,BufRead *.ts setlocal shiftwidth=4 tabstop=4 softtabstop=4
augroup END

" Display that extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Key to insert mode with paste
map <Leader>i :set paste<CR>i
" Leave paste mode on exit
au InsertLeave * set nopaste

map <F7> :vertical resize 90<CR>
map <F9> :NERDTreeToggle<CR>

" Current window management
map M :tabe %<CR>
map m :tabc<CR>

" Preprocess long lines
command! FormatLongLines :%!fmt -80 -s

" Quick commands for formatting serialized data
command! FormatJSON :%!ruby -rjson -e 'puts JSON.pretty_generate(JSON.parse(STDIN.read))'
command! FormatYAML :%!ruby -ryaml -e 'puts YAML.load(STDIN.read).to_yaml'
command! FormatXML :%!xmllint --format -
command! ConvertJSON2YAML :%!ruby -ryaml -rjson -e 'puts JSON.parse(STDIN.read).to_yaml'
command! ConvertYAML2JSON :%!ruby -ryaml -rjson -e 'puts YAML.load(STDIN.read).to_json'

" Read output from executed command in new buffer
command! -nargs=* -complete=shellcmd Read new | setlocal buftype=nofile bufhidden=hide noswapfile | r !<args>

" Copy to system clipboard (requires vim clipboard support)
:vnoremap Y "+y<CR>

nnoremap <Leader>b :buffers<CR>:buffer<Space>

" Zeal docs
map <Leader>z :Zeavim!<CR>
vmap <Leader>z :ZeavimV<CR>

" ALE settings
let g:ale_completion_enabled = 1
let g:ale_completion_autoimport = 1
let g:ale_sign_column_always = 1
let g:ale_fix_on_save = 1
let g:ale_preview_item_open_in = 'tab'
let g:ale_set_balloons=1
set omnifunc=ale#completion#OmniFunc

map <Leader>d :ALEGoToDefinition -tab<CR>
map <Leader>r :ALEFindReferences -tab<CR>
map <Leader>g :ALEHover<CR>

let g:airline#extensions#ale#enabled = 1

" Vim-go
let g:go_gopls_enabled = 0
let g:go_highlight_types = 1
let g:go_highlight_functions = 1

" Don't select or insert automatically from omnicomplete list
setlocal completeopt=menu,menuone,preview,noselect,noinsert
" Omnicomplete tab select item from list
inoremap <expr><tab> pumvisible()?"\<c-n>":"\<tab>"
