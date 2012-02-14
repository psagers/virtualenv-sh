# Sets up zsh to autoload our functions from their source paths for
# development.
 
root=$(dirname $0)

fpath=($root/functions $root/functions/zsh $fpath)

funcs=(${fpath[1]}/*(.:t) ${fpath[2]}/*(.:t))

unfunction $funcs 2>/dev/null
autoload -U $funcs

virtualenv-sh-init
