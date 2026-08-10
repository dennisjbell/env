#
# .bash_profile
#
# This script is launched on new login shells (or every time you start bash on Mac OS X)

resources="$HOME/.profile $HOME/.bash_profile.local $HOME/.bashrc"
for resource in $resources ; do
  [[ -f $resource ]] && source $resource
done

# added by Snowflake SnowSQL installer v1.2
[[ -d /Applications/SnowSQL.app ]] && export PATH=/Applications/SnowSQL.app/Contents/MacOS:$PATH

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
[[ -s "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
