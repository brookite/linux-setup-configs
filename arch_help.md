# Экспорт зависимостей

```bash
pacman -Qqe | grep -vx "$(pacman -Qqg base-devel)" | grep -vx "$(pacman -Qqm)" > archlinux.lst
pacman -Qqm > archlinux_aur.lst
```

# Краткое руководство по установке Arch

1. Правильная разметка разделов
2. Настройка зеркал c помощью <https://archlinux.org/mirrorlist/>
3. Установка пакетов
