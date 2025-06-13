#!/bin/bash

set -e  # Остановиться при ошибке

echo "🔄 Обновление системы..."
sudo apt update
sudo apt dist-upgrade -y

echo "📦 Установка базовых пакетов из debian_server.lst..."
xargs -a debian_server.lst sudo apt install -y

# Если это Raspberry Pi OS — ставим дополнительные пакеты
if [ -f /etc/rpi-issue ]; then
  echo "🍓 Обнаружена Raspberry Pi OS! Установка дополнительных пакетов из raspberry.lst..."
  xargs -a raspberry.lst sudo apt install -y
fi

echo "✅ Базовые пакеты установлены."

# Temurin JDK
echo "☕ Установка Temurin JDK репозитория..."
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list

# Docker
echo "🐳 Настройка Docker репозитория..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Node JS
echo "🟢 Установка Node.js репозитория..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22
npm config set prefix '~/.local/'
bash npm_install.sh


# Rust
echo "🦀 Установка Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Установка JDK, Node и Docker после добавления реп
echo "🔄 Установка Temurin, Node.js и Docker..."
sudo apt-get update
sudo apt install -y temurin-21-jdk temurin-8-jdk
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Python: обновление pip и установка зависимостей
echo "🐍 Обновление python..."
bash pybuild.sh

# Neovim сборка
echo "📝 Сборка и установка Neovim..."
git clone --branch stable https://github.com/neovim/neovim
cd neovim
make CMAKE_BUILD_TYPE=Release
cd build
cpack -G DEB
DEB_PKG=$(find . -maxdepth 1 -name "nvim-*.deb" | head -n1)
mv "$DEB_PKG" nvim-linux64.deb
sudo dpkg -i nvim-linux64.deb
cd ../../
sudo rm -rf neovim

# LLVM установка
echo "🛠️ Установка LLVM 20..."
wget https://apt.llvm.org/llvm.sh
chmod u+x llvm.sh
sudo ./llvm.sh 20
rm llvm.sh

echo "🛠️ Установка Go..."
bash install_go.sh

echo "🎉 Установка завершена успешно!"
