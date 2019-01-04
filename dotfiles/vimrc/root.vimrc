let path = expand('<sfile>:h')
" echom expand('<sfile>:h')

exec 'source' path . '/vundle.vimrc'
exec 'source' path . '/plugins.vimrc'
exec 'source' path . '/filetypes.vimrc'
exec 'source' path . '/appearance.vimrc'
exec 'source' path . '/syntax.vimrc'
exec 'source' path . '/mappings.vimrc'

