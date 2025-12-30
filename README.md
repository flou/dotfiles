# Setup

Install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install basic Homebrew packages to setup all the rest
brew install git chezmoi
```

Then pull the `chezmoi` repository:

```bash
mkdir -p ~/workspace/github.com/flou
chezmoi init flou --source "${HOME}/workspace/github.com/flou/dotfiles"
ln -sv "${HOME}/workspace/github.com/flou/dotfiles" "${HOME}/.local/share/chezmoi"
chezmoi apply
```

## mise

Install `mise` plugins

```bash
mise install
```

### NixOS

Install Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate

cd ~/.config/nix-darwin
nix flake update
# Fist time
sudo -i nix run -- nix-darwin switch --flake ~/.config/nix-darwin

# Subsequent times
sudo -i darwin-rebuild switch --flake ~/.config/nix-darwin
```
