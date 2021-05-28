map <Leader>d :GoDef<CR>

autocmd BufWritePre,InsertLeave *.go ALEFix

let b:ale_fixers = ['goimports']
let b:ale_linters = ['gofmt']
