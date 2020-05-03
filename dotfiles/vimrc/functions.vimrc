" Common functions
" ===Location List Functions===
:function! ToggleLocationList()
  if get(getloclist(0, {'winid':0}), 'winid', 0)
      " the location window is open
      :lclose
  else
      " the location window is closed
      :YcmDiags
      " :lopen
  endif
endfunction

" ===Command Execution Functions===
:function! EnsurePreviousArgsDict()
:   if ! exists('b:previous_args_dict')
:     let b:previous_args_dict = {}
:   endif
:endfunction

" Previous args handling
:function! GetCommandArgsFromPreviousArgs(command, args_list)
: call EnsurePreviousArgsDict()
:
: let args_string=join(a:args_list, ' ')
:
: if len(a:args_list) > 0
:   let b:previous_args_dict[a:command] = args_string
: elseif has_key(b:previous_args_dict, a:command)
:   let args_string = get(b:previous_args_dict, a:command, '')
: endif
: echom "Args for command '" . a:command . "': '" . args_string . "'"
: return args_string
:endfunction

:function! ClearCommandPreviousArgs(command)
: call EnsurePreviousArgsDict()
:
: if has_key(b:previous_args_dict, a:command)
  : echom "Clearing previous commands which were: '". b:previous_args_dict[a:command] . "'"
:   call remove(b:previous_args_dict, a:command)
: endif
endfunction

:function! CreateCdHereAndRunCommand(command)
:  return 'cd ' . expand('%:h:p') . '; ' . a:command
:endfunction

" Executing commands
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

" Executing commands with previous arguments
:function! RunCommandWithPreviousArgs(command, args_list)
: let args_string = GetCommandArgsFromPreviousArgs(a:command, a:args_list)
: let full_command = a:command . ' ' . args_string
: call ExecuteAndShowCommand(full_command, full_command)
:endfunction

:function! RunExternalCommandWithPreviousArgs(command, args_list)
: let args_string = GetCommandArgsFromPreviousArgs(a:command, a:args_list)
: let command_with_args = a:command . ' ' . args_string
: let full_command = '!' . command_with_args
: call ExecuteAndShowCommand(full_command, command_with_args)
:endfunction

:function! ClearScreenRunExternalCommandWithPreviousArgs(command, args_list)
: let args_string = GetCommandArgsFromPreviousArgs(a:command, a:args_list)
: let command_with_args = a:command . ' ' . args_string
: let full_command = '!clear && ' . command_with_args
: call ExecuteAndShowCommand(full_command, command_with_args)
:endfunction

:function! ClearPreviousClearScreenRunExternalCommandWithArgs(command, args_list)
: call ClearCommandPreviousArgs(a:command)
: call ClearScreenRunExternalCommandWithPreviousArgs(a:command, a:args_list)
:endfunction

" VarArgs...
:function! RunCommandWithPreviousVarArgs(command, ...)
: call RunCommandWithPreviousArgs(a:command, a:000)
:endfunction

:function! RunExternalCommandWithPreviousVarArgs(command, ...)
: call RunExternalCommandWithPreviousArgs(a:command, a:000)
:endfunction

:function! ClearPreviousRunExternalCommandWithVarArgs(command, ...)
: call ClearCommandPreviousArgs(a:command)
: call RunExternalCommandWithPreviousArgs(a:command, a:000)
:endfunction

:function! ClearScreenRunExternalCommandWithPreviousVarArgs(command, ...)
: call ClearScreenRunExternalCommandWithPreviousArgs(a:command, a:000)
:endfunction

:function! ClearPreviousClearScreenRunExternalCommandWithVarArgs(command, ...)
: call ClearPreviousClearScreenRunExternalCommandWithArgs(a:command, a:000)
:endfunction

:function! ClearScreenRunExternalCommandHereWithPreviousVarArgs(command, ...)
: call ClearScreenRunExternalCommandWithPreviousArgs(CreateCdHereAndRunCommand(a:command), a:000)
:endfunction

:function! ClearPreviousClearScreenRunExternalCommandHereWithVarArgs(command, ...)
: call ClearPreviousClearScreenRunExternalCommandWithArgs(CreateCdHereAndRunCommand(a:command), a:000)
:endfunction

" C++ functions
:function! InsertCppHeaderGuardBlockVarArgs(...)
: if a:0 > 0
:   let l:header_name = a:1
: else
:   let l:header_name = '_' . substitute(expand("%:t"), "\\.", "_", "g")
: endif
: let l:guard_block_name = toupper(l:header_name)
: let l:saveview = winsaveview()
:
: call append(0, '#ifndef ' . l:guard_block_name)
: call append(1, '#define ' . l:guard_block_name)
: call append('$', '#endif // ' . l:guard_block_name)
:
: call winrestview(l:saveview)
  
:endfunction
