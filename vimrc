set nocompatible

" Plugins are native vim 9 packages in ~/.vim/pack/plugins/start
filetype plugin indent on

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

let g:airline#extensions#ale#enabled = 1

" LSP settings
" The vscode-eslint server reads its settings with no defaults of its own, so
" a partial dict just makes it throw on the first missing key. Every field
" below is load-bearing. It also wants them flat, not under an 'eslint' key -
" it asks for section "" and the plugin hands back the whole dict.
function! s:EslintConfig() abort
  let root = getcwd()
  " Derived from node's location so a version bump doesn't break this
  let node_modules = fnamemodify(exepath('node'), ':h:h') . '/lib/node_modules'

  return #{
        \ validate: 'on',
        \ run: 'onType',
        \ quiet: v:false,
        \ format: v:false,
        \ useESLintClass: v:true,
        \ experimental: {},
        \ nodePath: node_modules,
        \ onIgnoredFiles: 'off',
        \ options: {},
        \ rulesCustomizations: [],
        \ problems: #{ shortenToSingleLine: v:false },
        \ workingDirectory: #{ mode: 'auto' },
        \ workspaceFolder: #{ uri: 'file://' . root, name: fnamemodify(root, ':t') },
        \ codeAction: #{
        \   disableRuleComment: #{ enable: v:true, location: 'separateLine' },
        \   showDocumentation: #{ enable: v:true },
        \ },
        \ codeActionOnSave: #{ enable: v:false, mode: 'all' },
        \ }
endfunction

" Native packages load after the vimrc, so LspAddServer()/LspOptionsSet()
" don't exist yet - register on VimEnter once the plugin is loaded.
function! s:SetupLsp() abort
  call LspOptionsSet(#{
        \   autoComplete: v:true,
        \   autoHighlightDiags: v:true,
        \   showDiagInPopup: v:true,
        \   ignoreMissingServer: v:true,
        \ })

  let servers = [
        \ #{ name: 'golang',     filetype: ['go', 'gomod'],
        \    path: 'gopls', args: ['serve'], syncInit: v:true },
        \ #{ name: 'typescript', filetype: ['javascript', 'typescript', 'typescriptreact'],
        \    path: 'typescript-language-server', args: ['--stdio'] },
        \ #{ name: 'eslint',     filetype: ['javascript', 'typescript', 'typescriptreact'],
        \    path: 'vscode-eslint-language-server', args: ['--stdio'],
        \    workspaceConfig: s:EslintConfig() },
        \ #{ name: 'json',       filetype: ['json'],
        \    path: 'vscode-json-language-server', args: ['--stdio'],
        \    initializationOptions: #{ provideFormatter: v:true } },
        \ #{ name: 'yaml',       filetype: ['yaml'],
        \    path: 'yaml-language-server', args: ['--stdio'] },
        \ #{ name: 'ruby',       filetype: ['ruby'],
        \    path: 'ruby-lsp', args: [] },
        \ #{ name: 'terraform',  filetype: ['terraform'],
        \    path: 'terraform-ls', args: ['serve'] },
        \ #{ name: 'bash',       filetype: ['sh'],
        \    path: 'bash-language-server', args: ['start'] },
        \ #{ name: 'swift',      filetype: ['swift'],
        \    path: 'sourcekit-lsp', args: [] },
        \ ]

  " Only register servers actually installed, resolved to a full path
  for server in servers
    if executable(server.path)
      let server.path = exepath(server.path)
      call LspAddServer([server])
    endif
  endfor
endfunction

autocmd VimEnter * call s:SetupLsp()

map <Leader>d :vert :LspGotoDefinition<CR>
map <Leader>r :LspShowReferences<CR>
map <Leader>g :LspHover<CR>
map <Leader>n :LspRename<CR>
map <Leader>a :LspCodeAction<CR>
map <Leader>s :LspDocumentSymbol<CR>

" Vim-go
let g:go_gopls_enabled = 0
let g:go_highlight_types = 1
let g:go_highlight_functions = 1

" Don't select or insert automatically from omnicomplete list
set completeopt=menu,menuone,preview,noselect,noinsert
" Omnicomplete tab select item from list
inoremap <expr><tab> pumvisible()?"\<c-n>":"\<tab>"
