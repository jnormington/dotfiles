" Display function signature in omnicomplete
let g:tsuquyomi_completion_detail = 1
let g:tsuquyomi_disable_quickfix = 1
let g:typescript_indent_disable = 1

map <Leader>d :TsuDefinition<CR>

autocmd BufWritePre *.ts :silent Neoformat
autocmd BufWritePre,InsertLeave *.ts ALEFix
