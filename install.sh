#!/bin/bash
set -euo pipefail

install_base() {
	echo "Installing base tools..."
	sudo apt update
	sudo apt install -y curl gpg lsb-release ca-certificates
}

install_bottles() {
	echo "Installing Bottles via Flatpak..."
	sudo apt install -y flatpak
	sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install -y flathub com.usebottles.bottles
}

install_docker() {
	if ! command -v docker &>/dev/null; then
		echo "Installing Docker..."
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
		sudo apt update
		sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
		sudo usermod -aG docker "$USER"
	else
		echo "Docker already installed."
	fi
}

install_vscode() {
	if ! command -v code &>/dev/null; then
		echo "Installing VS Code..."
		curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg >/dev/null
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/packages.microsoft.gpg] \
    https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
		sudo apt update
		sudo apt install -y code
	else
		echo "VS Code already installed."
	fi
}

install_brave() {
	if ! command -v brave-browser &>/dev/null; then
		echo "Installing Brave Browser..."
		sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
		sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
		sudo apt update
		sudo apt install brave-browser
	else
		echo "Brave Browser already installed."
	fi
}

install_discord() {
	if ! command -v discord &>/dev/null; then
		echo "Installing Discord..."
		sudo snap install discord
	else
		echo "Discord already installed."
	fi
}

install_cli_tools() {
	sudo apt install eza fd-find ripgrep
	sudo snap install zellij --classic
	sudo snap install yazi --classic
	sudo snap install bottom
	# Install micro editor via snap
	sudo snap install micro --classic
}

install_node() {
	if ! command -v fnm &>/dev/null; then
		echo "Installing fnm (Fast Node Manager)..."
		curl -fsSL https://fnm.vercel.app/install | bash
		# Source fnm
		export PATH="/home/$USER/.local/share/fnm:$PATH"
		eval "$(fnm env --use-on-cd)"
	else
		echo "fnm already installed."
	fi

	echo "Installing latest stable Node.js..."
	fnm install --lts
	fnm use lts-latest
}

install_gemini() {
	if ! command -v node &>/dev/null; then
		echo "Node.js is required for Gemini CLI. Installing Node.js first..."
		install_node
	fi

	echo "Installing Gemini CLI..."
	npm install -g @google/gemini-cli@latest
}

show_help() {
	echo "Usage: $0 [docker] [vscode] [brave] [discord] [cli-tools] [all]"
	echo "  docker     : Install Docker"
	echo "  vscode     : Install VS Code"
	echo "  brave      : Install Brave Browser"
	echo "  discord    : Install Discord"
	echo "  cli-tools  : Install modern CLI tools (fd-find, eza, ripgrep)"
	echo "  node       : Install fnm and latest stable Node.js"
	echo "  gemini     : Install Google Gemini CLI"
	echo "  bottles    : Install Bottles via Flatpak"
	echo "  all        : Install all tools"
	exit 1
}

if [ $# -eq 0 ]; then
	show_help
fi

for arg in "$@"; do
	case "$arg" in
	docker)
		install_base
		install_docker
		;;
	vscode)
		install_base
		install_vscode
		;;
	brave)
		install_base
		install_brave
		;;
	discord)
		install_base
		install_discord
		;;
	cli-tools)
		install_base
		install_cli_tools
		;;
	node)
		install_base
		install_node
		;;
	gemini)
		install_base
		install_gemini
		;;
	bottles)
		install_base
		install_bottles
		;;
	all)
		install_base
		install_docker
		install_vscode
		install_brave
		install_discord
		install_cli_tools
		install_node
		install_gemini
		;;
	*)
		echo "Unknown option: $arg"
		show_help
		;;
	esac
done

echo "Setup completed!"
