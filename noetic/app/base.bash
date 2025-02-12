#!/bin/bash

set -e

USER=${1:-"robot"}

arch=$(uname -m)

if cat /etc/issue | grep -q "Ubuntu 24.04"; then
  if [ "$arch" == "x86_64" ]; then
    sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources
  elif [ "$arch" == "aarch64" ]; then
    sed -i 's/ports.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources
    # orin
    sed -i 's/repo.download.nvidia.com/repo.download.nvidia.cn/g' /etc/apt/sources.list.d/ubuntu.sources
  fi
  # ubuntu 24.04 删除 ubuntu 用户
  userdel -r ubuntu
elif cat /etc/issue | grep -q "Ubuntu"; then
  if [ "$arch" == "x86_64" ]; then
    sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
  elif [ "$arch" == "aarch64" ]; then
    sed -i 's/ports.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
    # orin
    sed -i 's/repo.download.nvidia.com/repo.download.nvidia.cn/g' /etc/apt/sources.list
  fi
fi

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get update 2>&1 | tee /tmp/apt.err && \
apt-get install --assume-yes --no-install-recommends --quiet=2 \
  ca-certificates \
  gnupg2 \
  locales \
  lsb-release \
  sudo \
  git \
  openssh-client \
  bash-completion\
  2>&1 | tee -a /tmp/apt.err \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Look for non-fatal apt errors and exit if found
if grep -q '^[E]:' /tmp/apt.err; then
  printf "ERROR: apt failure\n"
  return 1
fi

# Generate English locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
  locale-gen

sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

# Create $USER
useradd --create-home --user-group --groups sudo --shell /bin/bash "$USER"

# Add sudo permission for $USER
mkdir -p /etc/sudoers.d
printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' "$USER" | \
  tee /etc/sudoers.d/nopasswd

chmod 440 /etc/sudoers.d/nopasswd
mkdir -p /var/lib/sudo/lectured/
touch /var/lib/sudo/lectured/"$USER"
chmod 600 /var/lib/sudo/lectured/"$USER"
