#
# .bash_profile
#
# This script is launched on new login shells (or every time you start bash on Mac OS X)

resources="$HOME/.profile $HOME/.bash_profile.local $HOME/.bashrc"
for resource in $resources ; do
  [[ -f $resource ]] && source $resource
done

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
