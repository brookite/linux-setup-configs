#!/bin/bash

set -e  # Остановиться при ошибке

echo "🔎 Определение последней версии Go..."
GO_LATEST=$(curl -s https://go.dev/VERSION?m=text | head -n 1)
echo "👉 Последняя версия: $GO_LATEST"

# Определяем архитектуру
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    armv6l|armv7l) ARCH="armv6l" ;;  # Go для ARMv6 (подходит для armhf)
    *) echo "❌ Неизвестная архитектура: $ARCH" && exit 1 ;;
esac

# Формируем имя архива
GO_ARCHIVE="${GO_LATEST}.linux-${ARCH}.tar.gz"
DOWNLOAD_URL="https://go.dev/dl/${GO_ARCHIVE}"

echo "⬇️ Скачивание $GO_ARCHIVE..."
curl -O -L "$DOWNLOAD_URL"

# Удаляем старую версию Go
echo "🗑️ Удаление старой версии Go из /usr/local/go..."
sudo rm -rf /usr/local/go || true

# Распаковка архива
echo "📦 Установка новой версии Go..."
sudo tar -C /usr/local -xzf "$GO_ARCHIVE"

# Удаляем архив
rm "$GO_ARCHIVE"

# Выбор файла для настройки PATH
PROFILE_FILE="$HOME/.bashrc"
if [ -n "$ZSH_VERSION" ]; then
    PROFILE_FILE="$HOME/.zshrc"
fi

# Добавляем Go в PATH, если его там нет
if ! grep -q 'export PATH=.*go/bin' "$PROFILE_FILE"; then
    echo "🔧 Добавление Go в PATH в $PROFILE_FILE..."
    {
        echo ''
        echo '# GoLang'
        echo 'export PATH=$PATH:/usr/local/go/bin'
        echo 'export GOPATH=$HOME/go'
        echo 'export PATH=$PATH:$GOPATH/bin'
    } >> "$PROFILE_FILE"
    echo "✅ Путь для Go добавлен. Перезапусти терминал или выполни: source $PROFILE_FILE"
else
    echo "ℹ️ Go уже добавлен в PATH в $PROFILE_FILE"
fi

# Проверка версии
echo "🎉 Go успешно установлен! Текущая версия:"
export PATH=$PATH:/usr/local/go/bin
go version
