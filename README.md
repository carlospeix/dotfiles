# dotfiles

Based on [Nick Janetakis](https://github.com/nickjj/dotfiles) dotfiles repository

### Documentation

This configuration is designed an tested on a Windows 11 Pro host running WSL2 for development purpose.

#### On the windows host

On the windows host you should install WSL 2 and Docker Desktop for Windows, then install Ubuntu in WSL 2

#### Ubuntu 22.04 LTS

Basic tools

```sh
sudo apt-get update -y
sudo apt-get install -y curl git gpg htop rsync zip unzip rar unrar build-essential libssl-dev libreadline-dev zlib1g-dev
```

#### [GitHub cli](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)

```sh
sudo apt install gh -y
gh auth login
gh auth setup-git
```

#### [Heroku cli](https://devcenter.heroku.com/articles/heroku-cli)
```sh
curl https://cli-assets.heroku.com/install-ubuntu.sh | sh
```

#### [Docker engine](https://docs.docker.com/engine/install/ubuntu/)Add commentMore actions
```sh
sudo apt-get update
sudo apt-get install  ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

#### Install these dotfiles and various tools on your system

```sh
# Clone down this dotfiles repo to your home directory. Feel free to place
# this anywhere you want, but remember where you've cloned things to.
git clone https://github.com/carlospeix/dotfiles ~/dotfiles

# Copy WSL configuration
cp ~/dotfiles/c/Users/Carlos/.wslconfig /mnt/c/Users/carlos/.wslconfig 

# Create symlinks to various dotfiles. If you didn't clone it to ~/dotfiles
# then adjust the ln -s symlink source (left side) to where you cloned it.
#
# NOTE: The last one is WSL 1 / 2 specific. Don't do it on native Linux / MacOS.
mkdir -p ~/.local/bin && mkdir -p ~/.vim/spell && mkdir ~/.vim/colors \
  && ln -s ~/dotfiles/.aliases ~/.aliases \
  && ln -s ~/dotfiles/.bashrc ~/.bashrc \
  && ln -s ~/dotfiles/.gitconfig ~/.gitconfig \
  && ln -s ~/dotfiles/.profile ~/.profile \
  && ln -s ~/dotfiles/.vimrc ~/.vimrc \
  && ln -s ~/dotfiles/.vim/spell/en.utf-8.add ~/.vim/spell/en.utf-8.add \
  && ln -s ~/dotfiles/.vim/colors/default-light.vim ~/.vim/colors/default-light.vim \
  && ln -s ~/dotfiles/.local/bin/update-os ~/.local/bin/update-os \
  && sudo ln -s ~/dotfiles/etc/wsl.conf /etc/wsl.conf

#### Optionally confirm that a few things work after closing and re-opening your terminal

```sh
# Check to make sure git is configured with your name, email and custom settings.
git config --list
```

Before you start customizing certain config files, take a look at the
[personalization question in the FAQ](#how-to-personalize-these-dotfiles).

### Extra WSL 1 and WSL 2 steps

In addition to the Linux side of things, there's a few config files that I have
in various directories of this dotfiles repo. These have long Windows paths.

It would be expected that you copy those over to your system while replacing
"Carlos" with your Windows user name if you want to use those things, such as my
Microsoft Terminal `settings.json` file and others. Some of the paths may
also contain unique IDs too, so adjust them as needed on your end.

Some of these configs expect that you have certain programs or tools installed
on Windows. The [tools I use blog post](https://nickjanetakis.com/blog/the-tools-i-use) has a complete list of
those tools so you can pick the ones you want to install.

Pay very close attention to the `c/Users/carlos/.wslconfig` file because it has
values in there that you will very likely want to change before using it.
[This commit message](https://github.com/nickjj/dotfiles/commit/d0f1fc2622204b809cf7fcbb1a82d45b451064c4)
goes into the details.

Also, you should reboot to activate your `/etc/wsl.conf` file (symlinked
earlier). That will be necessary if you want to access your mounted drives at
`/c` or `/d` instead of `/mnt/c` or `/mnt/d`.
