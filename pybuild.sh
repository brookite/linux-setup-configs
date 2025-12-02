#!/bin/bash

set -e  # Остановится при любой ошибке
set -o pipefail

# 📥 Чтение основной версии Python из файла
PYTHON_MAJOR_MINOR=$(cat python_version.txt | tr -d ' \t\n')
echo "🔎 Ищем последнюю версию Python для ветки $PYTHON_MAJOR_MINOR..."

# 📡 Определение последней bugfix-версии
PYTHON_LATEST=$(curl -s https://www.python.org/ftp/python/ | grep -oP "$PYTHON_MAJOR_MINOR\.\d+/" | sort -V | tail -n1 | tr -d '/')
echo "👉 Найдена последняя версия: $PYTHON_LATEST"

START_DIR="$(pwd)"
cd ~

# 📦 Установка необходимых зависимостей для сборки
echo "📦 Установка сборочных пакетов..."
sudo apt update
sudo apt install -y build-essential gdb lcov pkg-config \
      libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
      libncurses-dev libreadline-dev libsqlite3-dev libssl-dev \
      lzma liblzma-dev tk-dev uuid-dev zlib1g-dev libzstd-dev \
      inetutils-inetd

# 📥 Скачивание исходников
echo "⬇️ Скачивание исходников Python $PYTHON_LATEST..."
wget "https://www.python.org/ftp/python/$PYTHON_LATEST/Python-$PYTHON_LATEST.tgz"

# 📦 Распаковка
tar -xf "Python-$PYTHON_LATEST.tgz"
cd "Python-$PYTHON_LATEST"


TOTAL_MEM_MB=$(grep MemTotal /proc/meminfo | awk '{print int($2/1024)}')

# ⚙️ Сборка и установка
echo "⚙️ Конфигурирование сборки..."


if [ "$TOTAL_MEM_MB" -ge 4000 ]; then
  ./configure --enable-optimizations --with-lto --with-computed-gotos --with-system-ffi --with-openssl=/usr --prefix=/usr/local

  echo "⚒️ Сборка (используется все ядра процессора)..."
  make -j$(nproc)
else 
  ./configure --enable-optimizations --with-computed-gotos --with-system-ffi --with-openssl=/usr --prefix=/usr/local

  echo "⚒️ Сборка..."
  make -j$(nproc) -l 4
fi


echo "🚀 Установка..."
sudo make altinstall  # altinstall чтобы не перезаписать /usr/bin/python3 напрямую

cd ..
sudo rm -rf "Python-$PYTHON_LATEST" "Python-$PYTHON_LATEST.tgz"

# 🔄 Регистрация в update-alternatives
PYTHON_BIN="/usr/local/bin/python${PYTHON_MAJOR_MINOR}"
PYTHON_VERSION_INSTALLED=$($PYTHON_BIN --version | awk '{print $2}')
echo "✅ Python $PYTHON_VERSION_INSTALLED установлен по пути $PYTHON_BIN"

#echo "🔧 Настройка update-alternatives..."
#sudo update-alternatives --install /usr/bin/python3 python3 $PYTHON_BIN 1
#sudo update-alternatives --set python3 $PYTHON_BIN

# 📦 Обновление pip, setuptools, wheel
echo "🐍 Обновление pip, setuptools, wheel..."
$PYTHON_BIN -m ensurepip --upgrade
$PYTHON_BIN -m pip config set global.break-system-packages true
$PYTHON_BIN -m pip install --upgrade pip setuptools wheel

cd "$START_DIR"

# 📄 Установка пакетов из requirements_console.txt
echo "📦 Установка зависимостей из requirements_console.txt..."
$PYTHON_BIN -m pip install -r requirements_console.txt

echo "📦 Установка uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh

# ✅ Финал
echo "🎉 Python $PYTHON_VERSION_INSTALLED успешно установлен и активирован как основной python3!"
python3 --version
