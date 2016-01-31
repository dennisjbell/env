#
# .bash_profile
#
# This script is launched on new login shells (or every time you start bash on Mac OS X)

resources="$HOME/.profile $HOME/.bash_profile.local $HOME/.bashrc"
for resource in $resources ; do
  [[ -f $resource ]] && source $resource
done
