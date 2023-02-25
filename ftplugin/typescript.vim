map <Leader>d :TsuDefinition<CR>
map <Leader>f :ALEFix<CR>

let b:ale_linters = ['eslint', 'prettier', 'tsserver']
let b:ale_fixers = ['eslint', 'prettier']
