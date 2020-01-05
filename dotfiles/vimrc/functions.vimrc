" Common functions
:function! GetCommandArgsFromPreviousArgs(args_list)
: let args_string=join(a:args_list, ' ')
: if len(a:args_list) > 0
:   let b:previous_args = args_string
: elseif exists('b:previous_args')
:   let args_string = b:previous_args
: endif
: return args_string
:endfunction

:function! ExecuteCommand(full_command)
: execute (a:full_command)
:endfunction

function! ShowCommand(full_command)
: redraw!
: echom a:full_command
:endfunction

:function! ExecuteAndShowCommand(full_command, show_command)
: call ExecuteCommand(a:full_command)
: call ShowCommand(a:show_command)
:endfunction

:function! RunCommandWithPreviousArgs(command, args_list)
: let args_string = GetCommandArgsFromPreviousArgs(a:args_list)
: let full_command = a:command . ' ' . args_string
: call ExecuteAndShowCommand(full_command, full_command)
:endfunction

:function! RunExternalCommandWithPreviousArgs(command, args_list)
: let args_string = GetCommandArgsFromPreviousArgs(a:args_list)
: let command_with_args = a:command . ' ' . args_string
: let full_command = '!' . command_with_args
: call ExecuteAndShowCommand(full_command, command_with_args)
:endfunction

:function! ClearScreenRunExternalCommandWithPreviousArgs(command, args_list)
: let args_string = GetCommandArgsFromPreviousArgs(a:args_list)
: let command_with_args = a:command . ' ' . args_string
: let full_command = '!clear & ' . command_with_args
: call ExecuteAndShowCommand(full_command, command_with_args)
:endfunction

:function! RunCommandWithPreviousVarArgs(command, ...)
: call RunCommandWithPreviousArgs(a:command, a:000)
:endfunction

:function! RunExternalCommandWithPreviousVarArgs(command, ...)
: call RunExternalCommandWithPreviousArgs(a:command, a:000)
:endfunction

:function! ClearPreviousRunExternalCommandWithVarArgs(command, ...)
: let b:previous_args = ''
: call RunExternalCommandWithPreviousArgs(a:command, a:000)
:endfunction

:function! ClearScreenRunExternalCommandWithPreviousVarArgs(command, ...)
" I don't know why we can't pass a:000 here
: let foo=a:000
" See several attempts at making this work.
" TODO Refactor so that once we have args_string we're good to go
": call call('ClearScreenRunExternalCommandWithPreviousArgs', [a:command, a:000])
": call ClearScreenRunExternalCommandWithPreviousArgs(a:command. foo)
": call ClearScreenRunExternalCommandWithPreviousArgs(a:command. a:000)
: let args_string = GetCommandArgsFromPreviousArgs(a:000)
: let command_with_args = a:command . ' ' . args_string
: let full_command = '!clear & ' . command_with_args
: call ExecuteAndShowCommand(full_command, command_with_args)
:endfunction

:function! ClearPreviousClearScreenRunExternalCommandWithVarArgs(command, ...)
: let b:previous_args = ''
: let foo=a:000
" See several attempts at making this work.
" TODO Refactor so that once we have args_string we're good to go
" Note that the call call below seemed to work ?!
": call call ('ClearScreenRunExternalCommandWithPreviousArgs', [a:command. a:000])
": call ClearScreenRunExternalCommandWithPreviousArgs(a:command. foo)
": call ClearScreenRunExternalCommandWithPreviousArgs(a:command. a:000)
: let args_string = GetCommandArgsFromPreviousArgs(a:000)
: let command_with_args = a:command . ' ' . args_string
: let full_command = '!clear & ' . command_with_args
: call ExecuteAndShowCommand(full_command, command_with_args)
:endfunction


