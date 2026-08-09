vim9script

# Format the current buffer with Prettier, on save or on demand. Everything
# else formats over LSP - see the FormatOnSave autocmds in the vimrc.
#
# Synchronous on purpose: the write cannot begin until the buffer has been
# rewritten, so running it async would be a blocking wait with extra steps.
#
# '%' in a command is replaced with the path of the file being formatted.
# when/unless gate a step on files found above it; .oxfmtrc.json means oxfmt.

const TIMEOUT = 5000

const PRETTIER = {
  cmd: ['prettier', '--stdin-filepath', '%'],
  when: ['.prettierrc', '.prettierrc.json', '.prettierrc.yml', '.prettierrc.yaml',
         '.prettierrc.js', '.prettierrc.cjs', '.prettierrc.mjs',
         'prettier.config.js', 'prettier.config.cjs', 'prettier.config.mjs'],
  unless: ['.oxfmtrc.json'],
}

var formatters: dict<list<dict<any>>> = {
  typescript:      [PRETTIER],
  typescriptreact: [PRETTIER],
  javascript:      [PRETTIER],
  json:            [PRETTIER],
  yaml:            [PRETTIER],
  markdown:        [PRETTIER],
  css:             [PRETTIER],
  html:            [PRETTIER],
}

# Searching from the file rather than :pwd keeps the answer right when one Vim
# session has buffers open from more than one project.
def AnyFound(names: list<string>): bool
  const from = $'{expand("%:p:h")};'

  for name in names
    if !findfile(name, from)->empty()
      return true
    endif
  endfor

  return false
enddef

# The version that formats the file should be the version CI checks it with.
def ResolveBin(name: string): string
  const dir = finddir('node_modules/.bin', $'{expand("%:p:h")};')
  const local = $'{dir}/{name}'

  return !dir->empty() && executable(local) ? local : name
enddef

# Run argv with 'input' on stdin and block until it exits.
def Run(argv: list<string>, input: list<string>): dict<any>
  var out: list<string> = []
  var err: list<string> = []
  var code = -1

  var job = job_start(argv, {
    mode: 'nl',
    in_io: 'pipe',
    out_cb: (_, msg: string) => add(out, msg),
    err_cb: (_, msg: string) => add(err, msg),
    exit_cb: (_, status: number) => {
      code = status
    },
  })

  if job_status(job) != 'run'
    return {code: -1, out: [], err: [$'could not start {argv[0]}']}
  endif

  var ch = job_getchannel(job)
  ch_sendraw(ch, input->join("\n") .. "\n")
  ch_close_in(ch)

  # sleep lets Vim run the channel callbacks while we wait
  var waited = 0
  while code < 0 && waited < TIMEOUT
    sleep 5m
    waited += 5
  endwhile

  if code < 0
    job_stop(job, 'kill')
    return {code: -1, out: [], err: [$'{argv[0]} timed out after {TIMEOUT}ms']}
  endif

  # exit_cb can fire before the last of the output has been read
  while ch_status(ch) == 'buffered'
    add(out, ch_read(ch))
  endwhile

  return {code: code, out: out, err: err}
enddef

def g:FormatBuffer(): void
  if !formatters->has_key(&filetype)
    return
  endif

  var path = expand('%:p')
  var text = getline(1, '$')

  for step in formatters[&filetype]
    if step->has_key('when') && !AnyFound(step.when)
      continue
    endif

    if step->has_key('unless') && AnyFound(step.unless)
      continue
    endif

    var argv = step.cmd->copy()->map((_, v) => v == '%' ? path : v)
    argv[0] = ResolveBin(argv[0])

    if !executable(argv[0])
      continue
    endif

    var result = Run(argv, text)

    if result.code != 0
      # Nearly always a syntax error - leave the buffer untouched rather than
      # writing mangled output, and say why.
      var reason = result.err->empty() ? $'exit {result.code}' : result.err[0]
      echohl WarningMsg
      echomsg $'{argv[0]}: {reason}'
      echohl None
      return
    endif

    text = result.out
  endfor

  if text == getline(1, '$')
    return
  endif

  # Overwrite in place so marks and the undo tree survive better
  var view = winsaveview()
  setline(1, text)
  if line('$') > len(text)
    silent execute $':{len(text) + 1},$delete _'
  endif
  winrestview(view)
enddef

command! Format g:FormatBuffer()

augroup FormatOnSave
  autocmd!
  autocmd BufWritePre * g:FormatBuffer()
augroup END
