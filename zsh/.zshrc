# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="af-magic"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    sudo
    copyfile
    web-search
    docker
)

source $ZSH/oh-my-zsh.sh

export PATH=$PATH:/usr/local/go/bin
export PATH="$HOME/go/bin:$PATH"