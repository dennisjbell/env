# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Don't source twice...
type _bash_history_sync > /dev/null 2>&1 && return

# PATH
export PATH="$HOME/bin:$PATH"

# RVM Support
[[ -d "$HOME/.rvm/bin" ]] && [[ -f "$HOME/.bashrc.rvm" ]] && source $HOME/.bashrc.rvm

# If not running interactively, don't do anything else
[ -z "$PS1" ] && return

# =============================================================================
# History configuration
# -----------------------------------------------------------------------------
HISTSIZE=9000
HISTFILESIZE=$HISTSIZE
HISTCONTROL=ignoreboth # sam as 'ignorespace:ignoredups'

_bash_history_sync() {
  builtin history -a         #1
  HISTFILESIZE=$HISTSIZE     #2
  builtin history -c         #3
  builtin history -r         #4
}

history() {                  #5
  _bash_history_sync
  builtin history "$@"
}
PROMPT_COMMAND=_bash_history_sync

# =============================================================================
# Prompt configuration
# -----------------------------------------------------------------------------
PSstatus="[\[\e[1;33m\]\!\[\e[0;39m\]/\$(err_code=\$?; if [ \$err_code == 0 ] ; then echo \"\[\e[0;32m\]0\[\e[0;39m\]\" ;else echo \"\[\e[1;31m\]\$err_code\[\e[0;39m\]\"; fi)] \[\e[1;36m\]\u\[\e[1;37m\]@\[\e[0;36m\]\h\[\e[1;37m\] "
PSgit="\[\e[0;35m\]\$(vcprompt)"
PSrvm="${PSrvm:-}"
PSprompt="\n\[\e[1;34m\]\w \[\e[1;37m\]∴\[\e[0;39m\] "

type git >/dev/null 2>&1
if [[ $? == 0 ]]; then
  export PS0="$PSstatus%{[git@%[\e[1;34m%]%b%[\e[00m%]:%[\e[1;33m%]%i%[\e[00m%]%}%{%[\e[1;31m%]%c%u%f%t%[\e[00m%]]%} $PSrvm$PSprompt"
  export PROMPT_COMMAND="${PROMPT_COMMAND}"';export PS1=$($HOME/bin/gitprompt c=\+ u=\* f=\? statuscount=1)'
else
  export PS1="$PSstatus$PSgit$PSrvm$PSprompt"
fi
# -----------------------------------------------------------------------------

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# Make ls nice and colourful
if [ "$TERM" != "dumb" ] && [ -x /usr/bin/dircolors ]; then
  eval $(dircolors)
  if ! ls --color=auto /enoent 2>&1 >/dev/null | grep -q illegal; then
    alias ls="ls --color=auto"
  fi
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
[[ -f /etc/bash_completion ]] && source /etc/bash_completion

# Load the OS-specific initializations
case $OSTYPE in
(darwin*)
  initializer="macosx";;
(linux*)
  DIST=$(lsb_release -si)
  case ${DIST} in
  (Ubuntu)
    initializer="ubuntu";;
  (*)
    initializer="linux";;
  esac;;
esac
[[ -f "$HOME/.bashrc.$initializer" ]] && source $HOME/.bashrc.$initializer

# Load the general and localized custom initialization
[[ -f "$HOME/.bashrc.custom" ]] && source $HOME/.bashrc.custom
[[ -f "$HOME/.bashrc.local" ]]  && source $HOME/.bashrc.local

# Make sure home bin directory is the first thing in the path
export PATH="$HOME/bin:$PATH"

# -----------------------------------------------------------------------------
# Anything appended below should be moved to .bashrc.local
# -----------------------------------------------------------------------------
