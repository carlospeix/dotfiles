#!/usr/bin/env bash
# This file runs every time you open a new terminal window.

# Limit number of lines and entries in the history. HISTFILESIZE controls the
# history file on disk and HISTSIZE controls lines stored in memory.
export HISTFILESIZE=50000
export HISTSIZE=50000

# Add a timestamp to each command.
export HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S:   "

# Duplicate lines and lines starting with a space are not put into the history.
export HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it.
shopt -s histappend

# Ensure $LINES and $COLUMNS always get updated.
shopt -s checkwinsize

# Enable bash completion.
[ -f /etc/bash_completion ] && source /etc/bash_completion

# Improve output of less for binary files.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Load aliases if they exist.
[ -f "${HOME}/.aliases" ] && source "${HOME}/.aliases"
[ -f "${HOME}/.aliases.local" ] && source "${HOME}/.aliases.local"

# Determine git branch.
parse_git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Set a non-distracting prompt.
PS1='\[\]\u@\h\[\]:\[\]\w\[\] \[\]$(parse_git_branch)\[\]\n\$ '

# If it's an xterm compatible terminal, set the title to user@host: dir.
case "${TERM}" in
xterm* | rxvt*)
  PS1="\[\e]0;\u@\h: \w\a\]${PS1}"
  ;;
*) ;;
esac

export PATH=~/.npm-global/bin:$PATH
export PATH="$(ruby -e 'puts Gem.user_dir')/bin:$PATH"

# Fixed SSH agent socket path (avoids stale socket issues with devcontainers)
export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"

export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"

if [ -f ~/.ssh-agent-env ]; then
  source ~/.ssh-agent-env >/dev/null
fi

if ! ssh-add -l >/dev/null 2>&1; then
  # Kill stale socket if exists
  rm -f "$SSH_AUTH_SOCK"
  eval "$(ssh-agent -a "$SSH_AUTH_SOCK" -s)"
  echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >~/.ssh-agent-env
  echo "SSH agent started."
else
  echo "SSH agent already running."
fi
for key in ~/.ssh/hetzner_id_ed25519 ~/.ssh/github_signing_wsl; do
  fp="$(ssh-keygen -lf "$key" | awk '{print $2}')"
  ssh-add -l | grep -q "$fp" || ssh-add "$key"
done

if [ -f ~/.bashrc_private ]; then
  source ~/.bashrc_private
fi
