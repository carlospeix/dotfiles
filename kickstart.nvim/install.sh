#!/bin/bash

cd /tmp
curl -L -o nvim.tar.gz "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"
tar -xf nvim.tar.gz
sudo install nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
sudo cp -R nvim-linux-x86_64/lib /usr/local/
sudo cp -R nvim-linux-x86_64/share /usr/local/
rm -rf nvim-linux-x86_64 nvim.tar.gz
cd -

# FONT_FILE="CascadiaCode.zip"
# wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/$FONT_FILE &&
#   cd ~/.local/share/fonts &&
#   unzip $FONT_FILE &&
#   rm $FONT_FILE &&
#   fc-cache -fv

# Install luarocks and tree-sitter-cli to resolve lazyvim :checkhealth warnings
# npm install -g tree-sitter-cli

# Only attempt to set configuration if Neovim has never been run
if [ ! -d "$HOME/.config/nvim" ]; then
  mkdir $HOME/.config/nvim
  curl -L -o $HOME/.config/nvim/init.lua https://raw.githubusercontent.com/nvim-lua/kickstart.nvim/refs/heads/master/init.lua
fi

