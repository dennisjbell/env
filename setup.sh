#!/bin/bash 

set -e

rpath() {
  if command realpath > /dev/null 2>&1
  then
    realpath "$1"
  else
    echo "$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")"
  fi
}

basedir="$(rpath $(dirname $0))"

if [[ -z "${basedir}" ]]
then
  echo "Could not determine base directory for env repo"
  exit 1
fi

cd $HOME

backupdir="${HOME}/.dotfiles-backup"
mkdir -p $backupdir
shopt -s nullglob
for file in .bash* .{g,}vim* .git*
do
  if [ ! -L $file ] ; then mv ${file} ${backupdir}; fi
done

for file in ${basedir}/.bash* ${basedir}/git/.??* ${basedir}/vimfiles/.{g,}vim*; do
  ln -sfn $file $HOME/
done

mkdir -p ${HOME}/bin
for file in ${basedir}/bin/*; do
  ln -sfn $file ${HOME}/bin/
done

mkdir -p $HOME/tmp/vim-backups

cd .vim
#TODO check required libraries and run this
echo "Run ~/.vim/update_bundles"
