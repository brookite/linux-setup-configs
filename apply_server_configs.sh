#!/bin/bash
set -e

USER_HOME=$(eval echo ~${SUDO_USER})
SHARED_DIR="$USER_HOME/shared"

echo "📂 Создаём папку для обмена файлами: $SHARED_DIR"
mkdir -p "$SHARED_DIR"
chown "$SUDO_USER:$SUDO_USER" "$SHARED_DIR"
chmod 770 "$SHARED_DIR"

# 📝 Установка Samba
echo "📦 Устанавливаем Samba и vsftpd..."
sudo apt update
sudo apt install -y samba vsftpd gnupg openssh-server

echo "📄 Копируем конфиги..."
sudo cp configs/smb.conf /etc/samba/smb.conf
sudo cp configs/vsftpd.conf /etc/vsftpd.conf

# 🔄 Перезапуск сервисов
echo "🚀 Перезапускаем службы Samba и FTP..."
sudo systemctl restart smbd
sudo systemctl restart vsftpd
sudo systemctl enable smbd
sudo systemctl enable vsftpd

# 🗝️ Перенос ключей
echo "🔐 Переносим ключи..."

# SSH ключи
if compgen -G "keys/*.ssh.pub" > /dev/null; then
  echo "➡️ Устанавливаем публичные SSH ключи..."
  mkdir -p "$USER_HOME/.ssh"
  cat keys/*.ssh.pub >> "$USER_HOME/.ssh/authorized_keys"
  chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/.ssh"
  chmod 700 "$USER_HOME/.ssh"
  chmod 600 "$USER_HOME/.ssh/authorized_keys"
fi

if compgen -G "keys/*.ssh.key" > /dev/null; then
  echo "➡️ Переносим приватные SSH ключи..."
  for key in keys/*.ssh.key; do
    cp "$key" "$USER_HOME/.ssh/"
    chmod 600 "$USER_HOME/.ssh/$(basename "$key")"
  done
fi

# GPG ключи
if compgen -G "keys/*.gpg.pub" > /dev/null; then
  echo "➡️ Импортируем публичные GPG ключи..."
  for key in keys/*.gpg.pub; do
    sudo -u "$SUDO_USER" gpg --import "$key"
  done
fi

if compgen -G "keys/*.gpg.key" > /dev/null; then
  echo "➡️ Импортируем приватные GPG ключи..."
  for key in keys/*.gpg.key; do
    sudo -u "$SUDO_USER" gpg --import "$key"
  done
fi

sudo smbpasswd -a $USER

echo "✅ Настройка завершена!"
