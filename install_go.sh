#!/bin/bash

set -e  # Остановится при ошибке

# Определяем последнюю версию Go с официального сайта
echo "🔎 Определение последней версии Go..."
GO_LATEST=$(curl -s https://go.dev/VERSION?m=text)
echo "👉 Последняя версия: $GO_LATEST"

# Формируем ссылку на архив
GO_ARCHIVE="${GO_LATEST}.linux-amd64.tar.gz"
DOWNLOAD_URL="https://go.dev/dl/${GO_ARCHIVE}"

# Скачиваем архив
echo "⬇️ Скачивание $GO_ARCHIVE..."
curl -O "$DOWNLOAD_URL"

# Удаляем старую версию Go (если есть)
echo "🗑️ Удаление старой версии Go из /usr/local/go..."
sudo rm -rf /usr/local/go

# Распаковываем архив в /usr/local
echo "📦 Установка новой версии Go..."
sudo tar -C /usr/local -xzf "$GO_ARCHIVE"

# Удаляем архив
rm "$GO_ARCHIVE"

# Проверяем, есть ли уже запись в .bashrc или .zshrc
PROFILE_FILE="$HOME/.bashrc"
if [ -n "$ZSH_VERSION" ]; then
  PROFILE_FILE="$HOME/.zshrc"
fi

# Добавляем Go в PATH, если его там нет
if ! grep -q 'export PATH=$PATH:/usr/local/go/bin' "$PROFILE_FILE"; then
  echo "🔧 Добавление Go в PATH в $PROFILE_FILE..."
  echo '' >> "$PROFILE_FILE"
  echo '# GoLang' >> "$PROFILE_FILE"
  echo 'export PATH=$PATH:/usr/local/go/bin' >> "$PROFILE_FILE"
  echo 'export GOPATH=$HOME/go' >> "$PROFILE_FILE"
  echo 'export PATH=$PATH:$GOPATH/bin' >> "$PROFILE_FILE"
  echo "✅ Путь для Go добавлен. Перезапусти терминал или выполни: source $PROFILE_FILE"
else
  echo "ℹ️ Go уже добавлен в PATH в $PROFILE_FILE"
fi

# Вывод установленной версии
echo "🎉 Go успешно установлен! Текущая версия:"
export PATH=$PATH:/usr/local/go/bin
go version
