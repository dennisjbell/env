# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Don't source twice...
type _bash_history_sync > /dev/null 2>&1 && return
if [[ -n "$DJBELL_BASE" ]] ; then
  export DJBELL_BASE="$DJBELL_BASE"
else
  export DJBELL_BASE="$HOME"
fi

# PATH
export PATH="$DJBELL_BASE/bin:$PATH"

# Perlbrew support (think rvm for perl)
[[ -d "$DJBELL_BASE/perl5/perlbrew/etc/" && -f "$DJBELL_BASE/perl5/perlbrew/etc/bashrc" ]] && source $DJBELL_BASE/perl5/perlbrew/etc/bashrc

# RVM Support
[[ -d "$DJBELL_BASE/.rvm/bin" ]] && [[ -f "$DJBELL_BASE/.bashrc.rvm" ]] && source $DJBELL_BASE/.bashrc.rvm

# PerlBrew Support
[[ -d "$DJBELL_BASE/perl5/perlbrew/etc" ]] && [[ -f "$DJBELL_BASE/perl5/perlbrew/etc/bashrc" ]] && source "$DJBELL_BASE/perl5/perlbrew/etc/bashrc"

# If not running interactively, don't do anything else
[ -z "$PS1" ] && return

# =============================================================================
# History configuration
# -----------------------------------------------------------------------------
HISTSIZE=50000
HISTFILESIZE=$HISTSIZE
HISTCONTROL=ignoredups # sam as 'ignorespace:ignoredups'

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
PSstatus="[\[\e[1;33m\]\!\[\e[0;39m\]/\$(err_code=\$?; if [ \$err_code == 0 ] ; then echo \"\[\e[0;32m\]0\[\e[0;39m\]\" ;else echo \"\[\e[1;31m\]\$err_code\[\e[0;39m\]\"; fi)/\[\e[0;36m\]\$($DJBELL_BASE/bin/tt --prompt)\[\e[1;37m\]] \[\e[1;36m\]\u\[\e[1;37m\]@\[\e[0;36m\]\h\[\e[1;37m\] "
PSgit="\[\e[0;35m\]\$(vcprompt)"
PSrvm="${PSrvm:-}"
PSprompt="\n\[\e[1;34m\]\w \[\e[1;37m\]∴\[\e[0;39m\] "
PStt="\$(tt --prompt) "
PSk8s="[\[\e[1;37m\]K8S:\[\e[0;33m\]\$(kubens -c)\[\e[1;33m\]@\[\e[1;32m\]\$(kubectx -c)\[\e[0m\]] "
command kubens &> /dev/null && command kubectx &> /dev/null  || PSk8s=''

type git >/dev/null 2>&1
if [[ $? == 0 ]]; then
  bash_v="$(bash --version | grep 'GNU bash, version' | sed -e 's/.*version \([0-9]\).*/\1/')"
  if [[ "$bash_v" == '4' ]]; then 
    export PS00="$PSstatus%{[git@%[\e[1;34m%]%b%[\e[00m%]:%[\e[1;33m%]%i%[\e[00m%]%}%{%[\e[1;31m%]%c%u%f%t%[\e[00m%]]%}$PSk8s$PSrvm$PSprompt"
  else
    export PS0="$PSstatus%{[git@%[\e[1;34m%]%b%[\e[00m%]:%[\e[1;33m%]%i%[\e[00m%]%}%{%[\e[1;31m%]%c%u%f%t%[\e[00m%]]%}$PSk8s$PSrvm$PSprompt"
  fi
  export PROMPT_COMMAND="${PROMPT_COMMAND}"';export PS1=$($DJBELL_BASE/bin/gitprompt c=\+ u=\* f=\? statuscount=1)'
else
  export PS1="$PSstatus$PSgit$PSk8s$PSrvm$PSprompt"
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
    echo "Ubuntu OS detected!"
    initializer="ubuntu";;
  (*)
    initializer="linux";;
  esac;;
esac
[[ -f "$DJBELL_BASE/.bashrc.$initializer" ]] && source $DJBELL_BASE/.bashrc.$initializer

# Load the general and localized custom initialization
[[ -f "$DJBELL_BASE/.bashrc.custom" ]] && source $DJBELL_BASE/.bashrc.custom
[[ -f "$DJBELL_BASE/.bashrc.local" ]]  && source $DJBELL_BASE/.bashrc.local

#Aliases files
[[ -f "$DJBELL_BASE/.bashrc.aliases" ]] && source $DJBELL_BASE/.bashrc.aliases
[[ -f "$DJBELL_BASE/.bashrc.aliases.$initializer" ]] && source $DJBELL_BASE/.bashrc.aliases.$initializer

# Make sure home bin directory is the first thing in the path
export PATH="$DJBELL_BASE/bin:$PATH"

# Predictable SSH authentication socket location.
SOCK="/tmp/ssh-agent-$USER-tmux"
if test $SSH_AUTH_SOCK && [ $SSH_AUTH_SOCK != $SOCK ]
then
    rm -f $SOCK
    ln -sf $SSH_AUTH_SOCK $SOCK
    export SSH_AUTH_SOCK=$SOCK
fi

RVM_LATE_BINDING=1
[[ -d "$DJBELL_BASE/.rvm/bin" ]] && [[ -f "$DJBELL_BASE/.bashrc.rvm" ]] && source $DJBELL_BASE/.bashrc.rvm


# -----------------------------------------------------------------------------
# Anything appended below should be moved to .bashrc.local
# -----------------------------------------------------------------------------

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$DJBELL_BASE/.rvm/bin"

[ -f $DJBELL_BASE/.fzf.bash ] && source $DJBELL_BASE/.fzf.bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
