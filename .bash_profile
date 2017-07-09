# Put everything in .bashrc but let's keep .bash_profile around for OS X ~reasons~
if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi
