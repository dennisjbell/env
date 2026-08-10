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
[ -z "$PS1" ] || source "$HOME/.bashrc.interactive"

# -----------------------------------------------------------------------------
# Anything appended below should be moved to .bashrc.local
# -----------------------------------------------------------------------------
