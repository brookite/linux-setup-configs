termux-setup-storage

pkg upgrade
pkg install tur-repo termux-api -y
pkg install ncurses-utils curl wget git proot-distro openssl gnupg fakeroot mc openssh lz4 zstd 7zip rsync rclone -y
pkg install -y python rust nodejs-lts neovim openjdk-21 -y
pkg install -y libzmq libxml2 libxslt -y build-essential cmake fzf binutils binutils-gold llvmgold ninja -y
python -m pip install --upgrade setuptools wheel
pkg install python-numpy python-pillow python-pandas python-lxml python-scipy python-yt-dlp matplotlib ruff uv -y

pkg install llvm-15 -y
LLVM_CONFIG=/data/data/com.termux/files/usr/opt/libllvm-15/bin/llvm-config pip install llvmlite numba

unset LLVM_CONFIG
python -m pip install --upgrade -r requirements_termux.txt --extra-index-url https://termux-user-repository.github.io/pypi/

cargo install ripgrep tree-sitter-cli