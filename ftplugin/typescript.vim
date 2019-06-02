map <Leader>d :TsuDefinition<CR>
map <Leader>f :ALEFix<CR>

autocmd! BufWritePre *.ts :silent Neoformat
