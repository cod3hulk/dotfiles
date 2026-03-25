#!/bin/bash
if [ `uname` = 'Linux' ]
  [[ -s /usr/share/autojump/autojump.sh ]] && source /usr/share/autojump/autojump.sh
then
elif [ `uname` = 'Darwin' ]
then
  [[ -s $(brew --prefix)/etc/profile.d/autojump.sh  ]] && . $(brew --prefix)/etc/profile.d/autojump.sh
fi
