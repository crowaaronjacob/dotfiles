#!/bin/bash

# Create necessary directories
mkdir -p ~/.config

# Symlink Neovim config
ln -sf ~/dotfiles/.config/nvim ~/.config/nvim

# Symlink .zshrc
ln -sf ~/dotfiles/.zshrc ~/.zshrc

# Symlink .tmux.conf
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf

echo "Dotfiles installed successfully!"