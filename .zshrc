
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export TIPTAP_PRO_TOKEN=LiPNpgKJm//WsTGWqfI61JilYGLRYWRJYrhkvsFaVJyHSdc+pGujiogVhRm5FSad
export PATH="$PATH:$HOME/.rvm/bin"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH="$PATH:/Users/aaron/Documents/WebDriver/chromedriver"
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/aaron/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/aaron/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/aaron/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/aaron/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


. "$HOME/.cargo/env"

# Shopify Hydrogen alias to local projects
alias h2='$(npm prefix -s)/node_modules/.bin/shopify hydrogen'

# Start a tmux project workspace
dev() {
  local session_name=$(basename "$PWD")

  # If session already exists, just attach to it
  if tmux has-session -t "$session_name" 2>/dev/null; then
    echo "Attaching to existing tmux session '$session_name'"
    tmux attach -t "$session_name"
    return
  fi

  echo "Creating new tmux session '$session_name'..."

  # Start new detached session with window 0
  tmux new-session -d -s "$session_name" -c "$PWD" -n editor 'nvim'

  # Create window 1 for terminal/git tasks
  tmux new-window -t "$session_name" -n terminal -c "$PWD"

  # Select the editor window before attaching
  tmux select-window -t "$session_name:0"

  # Attach to the session
  tmux attach -t "$session_name"
}

# Automatically start a tmux session in a git project with 2 windows
auto_tmux() {
  if [[ -d .git || -n $(git rev-parse --git-dir 2>/dev/null) ]]; then
    local session_name
    session_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
      echo "Creating tmux session: $session_name"

      # Start detached session with window 0
      tmux new-session -d -s "$session_name" -c "$PWD" -n editor 'nvim'
      
      # Create window 1 for terminal
      tmux new-window -t "$session_name" -n terminal -c "$PWD"
    fi

    # Attach to session, starting in window 0 (editor)
    tmux select-window -t "$session_name:0"
    tmux attach -t "$session_name"
  fi
}

# Auto-run when you cd into a directory
chpwd() {
  if [[ -z "$TMUX" ]]; then
    auto_tmux
  fi
}


[ -f "/Users/aaron/.ghcup/env" ] && . "/Users/aaron/.ghcup/env" # ghcup-env
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
 eval "$(pyenv init -)"
fi
