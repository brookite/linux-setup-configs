#!/bin/bash

# Скрипт для настройки локалей EN и RU в Arch Linux

set -e

echo "Добавление локалей en_US.UTF-8 и ru_RU.UTF-8 в /etc/locale.gen..."

# Раскомментируем нужные строки (если закомментированы)
sed -i '/^#en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
sed -i '/^#ru_RU.UTF-8 UTF-8/s/^#//' /etc/locale.gen

echo "Генерация локалей..."
locale-gen

echo "Установка основной локали на ru_RU.UTF-8..."

# Запишем основную локаль в /etc/locale.conf
echo "LANG=ru_RU.UTF-8" > /etc/locale.conf

# Чтобы сохранить поддержку EN, можно дополнительно установить переменные LC_*
# если это нужно, добавим (по желанию пользователя)
# echo "LC_MESSAGES=en_US.UTF-8" >> /etc/locale.conf

echo "Настройка завершена!"

# Рекомендуется установить правильную локаль в текущей сессии
export LANG=ru_RU.UTF-8

echo "Обновление списка пакетов..."
sudo pacman -Syu --noconfirm

# Установка зависимостей для компиляции yay
echo "Установка зависимостей для yay..."
sudo pacman -S --needed base-devel git --noconfirm

# Скачиваем исходники yay из AUR
echo "Клонирование репозитория yay..."
cd /tmp
git clone https://aur.archlinux.org/cgit/aur.git/commit/?h=yay -b master yay

# Переходим в директорию yay
cd yay

# Строим и устанавливаем yay
echo "Сборка и установка yay..."
makepkg -si --noconfirm

# Проверяем установку yay
echo "Проверка установки yay..."
yay --version

echo "yay установлен и готов к использованию!"

# Установка официальных пакетов
echo "Установка пакетов из archlinux.lst..."

# Читаем файл, убираем пустые строки и лишние пробелы
mapfile -t packages < <(grep -v '^\s*$' archlinux.lst | sed 's/^\s*//;s/\s*$//')

if [ ${#packages[@]} -eq 0 ]; then
  echo "Файл archlinux.lst пуст или не найден валидных пакетов!"
else
  sudo pacman -S --needed --noconfirm "${packages[@]}"
  echo "Официальные пакеты успешно установлены!"
fi

# Установка AUR пакетов через yay
echo "Установка AUR пакетов из archinstall_aur.lst..."

# Читаем файл, убираем пустые строки и лишние пробелы
mapfile -t aur_packages < <(grep -v '^\s*$' archinstall_aur.lst | sed 's/^\s*//;s/\s*$//')

if [ ${#aur_packages[@]} -eq 0 ]; then
  echo "Файл archinstall_aur.lst пуст или не найден валидных пакетов!"
else
  yay -S --needed --noconfirm "${aur_packages[@]}"
  echo "AUR пакеты успешно установлены!"
fi

echo "Установка всех пакетов завершена успешно!"

echo "🔄 Обновление pip, setuptools и wheel..."
python -m pip install --upgrade pip setuptools wheel

echo "📦 Установка зависимостей из requirements.txt..."
python -m pip install --user -r requirements.txt -r apps_python.txt

echo "✅ Установка Python-зависимостей завершена."

echo "🔄 Запуск установки через npm..."
bash npm_install.sh

echo "🎉 Все зависимости установлены!"