vim9script

# Format the current buffer with external tools, on save or on demand.
#
# Format-on-save is deliberately synchronous. The write cannot begin until the
# buffer has been rewritten, so running the tools in the background and waiting
# on their exit callbacks is a blocking wait with extra steps - and gets the
# ordering wrong the moment anything is slow. Async is worth it for
# diagnostics, which can land whenever. It buys nothing here.
#
# Each filetype maps to a list of steps run in order. '%' in a command is
# replaced with the path of the file being formatted.
#
#   io: 'stdin'  buffer goes in on stdin, formatted text comes back on stdout
#   io: 'file'   the tool rewrites a file in place, so the buffer is staged to
#                a temp file *next to the real one* - tsconfig resolution walks
#                up from the file, so a path in /tmp would not be part of the
#                project - and read back afterwards
#
#   when: only run the step if this filename exists in the current directory
#         or any parent. Keeps tsconfig-dependent tools quiet in projects that
#         have no tsconfig.

const TIMEOUT = 5000

const PRETTIER = {cmd: ['prettier', '--stdin-filepath', '%'], io: 'stdin'}
const ORGANIZE = {cmd: ['organize-imports-cli', '%'], io: 'file',
                  when: 'tsconfig.json'}

var formatters: dict<list<dict<any>>> = {
  # goimports is gofmt plus add-missing/remove-unused in one pass, which is
  # why Go needs no equivalent of the organize step below
  go:              [{cmd: ['goimports', '-srcdir', '%'], io: 'stdin'}],

  # prettier only ever reprints the AST - it will not remove an unused import,
  # so organize-imports-cli runs first
  typescript:      [ORGANIZE, PRETTIER],
  typescriptreact: [ORGANIZE, PRETTIER],
  javascript:      [ORGANIZE, PRETTIER],

  json:            [PRETTIER],
  yaml:            [PRETTIER],
  markdown:        [PRETTIER],
  css:             [PRETTIER],
  html:            [PRETTIER],
}

# Run argv with 'input' on stdin and block until it exits. Returns the exit
# code alongside whatever came back on stdout and stderr.
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

# Stage 'lines' next to the real file, let the tool rewrite it, read it back.
def RunOnFile(argv: list<string>, lines: list<string>): dict<any>
  var dir = expand('%:p:h')
  var ext = expand('%:e')
  var tmp = $'{dir}/.{expand("%:t:r")}.fmt{ext->empty() ? "" : "." .. ext}'

  writefile(lines, tmp)

  var result: dict<any>
  try
    result = Run(argv->copy()->map((_, v) => v == '%' ? tmp : v), [])
    if result.code == 0
      result.out = readfile(tmp)
    endif
  finally
    delete(tmp)
  endtry

  return result
enddef

def g:FormatBuffer(): void
  if !formatters->has_key(&filetype)
    return
  endif

  var path = expand('%:p')
  var text = getline(1, '$')

  for step in formatters[&filetype]
    if step->has_key('when') && findfile(step.when, '.;')->empty()
      continue
    endif

    var argv = step.cmd->copy()
    if !executable(argv[0])
      continue
    endif

    var result = step.io == 'file'
          ? RunOnFile(argv, text)
          : Run(argv->map((_, v) => v == '%' ? path : v), text)

    if result.code != 0
      # Nearly always a syntax error. Leave the buffer untouched rather than
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

  # Overwrite in place rather than deleting first, so marks and the undo
  # tree survive better
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
