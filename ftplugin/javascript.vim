map <Leader>f :ALEFix<CR>

autocmd! BufWritePre *.ts :silent Neoformat

let b:ale_linters = ['eslint', 'prettier']
let b:ale_fixers = ['eslint', 'prettier']
