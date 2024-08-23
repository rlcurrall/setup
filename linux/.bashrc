# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# Path to your oh-my-bash installation.
export OSH="$HOME/.oh-my-bash"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-bash is loaded.
OSH_THEME="robbyrussell"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# To disable the uses of "sudo" by oh-my-bash, please set "false" to
# this variable.  The default behavior for the empty value is "true".
OMB_USE_SUDO=true

# Which completions would you like to load? (completions can be found in ~/.oh-my-bash/completions/*)
completions=(
  git
  ssh
  npm
  nvm
  docker
)

# Which aliases would you like to load? (aliases can be found in ~/.oh-my-bash/aliases/*)
aliases=(
  general
)

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-bash/plugins/*)
plugins=(
  git
  bashmarks
  npm
  nvm
)

source "$OSH"/oh-my-bash.sh

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Aliases
alias bat="batcat"
alias bc="bc -q"
alias grep="rg"
alias vim="nvim"

alias ls="eza -F -gh --group-directories-first --git --git-ignore --icons --color-scale all --hyperlink"
alias lh="ls -d .*"
alias lD="ls -D"
alias lc="ls -1"
alias ll="ls -l"
alias la="ll -a"
alias lA="ll --sort=acc"
alias lC="ll --sort=cr"
alias lM="ll --sort=mod"
alias lS="ll --sort=size"
alias lX="ll --sort=ext"
alias l="la -a"
alias lx="l -HimUuS"
alias lxa="lx -Z@"
alias lt="ls -T"

# Configure Custom Bin
export PATH=$HOME/.bin:$PATH

# Configure Local Bin
export PATH=$HOME/.local/bin:$PATH

# Configure Mise
eval "$(mise activate bash)"

# Configure Rust
. "$HOME/.cargo/env"

# Configure Android SDK
# export ANDROID_HOME=$HOME/Android/Sdk
# export NDK_HOME="$ANDROID_HOME/ndk/$(ls -1 $ANDROID_HOME/ndk)"
# export PATH=$PATH:$ANDROID_HOME/emulator
# export PATH=$PATH:$ANDROID_HOME/platform-tools

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
