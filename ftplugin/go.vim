map <Leader>d :GoDef<CR>

autocmd BufWritePre,InsertLeave *.go ALEFix

let b:ale_fixers = ['gofmt', 'goimports']
let b:ale_linters = ['gometalinter', 'gofmt', 'gopls']
