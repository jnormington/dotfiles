let g:ale_go_langserver_executable = 'gopls'
let g:go_highlight_structs = 1
let g:go_highlight_functions = 1

map <Leader>d :GoDef<CR>

autocmd BufWritePre,InsertLeave *.go ALEFix
