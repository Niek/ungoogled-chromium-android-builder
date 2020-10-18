#
#  Based on: https://git.droidware.info/wchen342/ungoogled-chromium-android/src/branch/master/.github/workflows/build.yml
#

FROM archlinux:latest

# Install deps
RUN \
  set -x && \
  sed -i "$(($(grep -n "\[multilib\]" /etc/pacman.conf | cut -f1 -d:) + 1))s/^#//g" /etc/pacman.conf && \
  pacman -Syq --noconfirm && \
  pacman -Sq --noconfirm lib32-glibc multilib-devel gnu-free-fonts jdk8-openjdk base base-devel json-glib libva protobuf jsoncpp python python2 gperf wget rsync tar unzip curl gnupg maven yasm mesa npm ninja git clang lld llvm quilt && \
  # Downgrade to older gn version, latest version doesn't work
  pacman -U --noconfirm https://archive.archlinux.org/packages/g/gn/gn-0.1731.5ed3c9cc-1-x86_64.pkg.tar.zst && \
  pacman -Scc --noconfirm && \
  curl -s "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" -o Miniconda3-latest-Linux-x86_64.sh && \
  chmod +x Miniconda3-latest-Linux-x86_64.sh && \
  ./Miniconda3-latest-Linux-x86_64.sh -b -p ~/anaconda && \
  rm -rf Miniconda3-latest-Linux-x86_64.sh && \
  source ~/anaconda/bin/activate && \
  conda init && \
  conda create -y --name py2 python=2 && \
  conda activate py2 && \
  pip install six

# Build
RUN \
  source ~/.bashrc && \
  conda activate py2 && \
  git clone https://git.droidware.info/wchen342/ungoogled-chromium-android.git && \
  cd ungoogled-chromium-android && \
  echo "use_egl=false" >> android_flags.gn && \
  # Switch to default Android channel / FIXME: remove this, not necessary
  #sed -i "s/stable/default/g" android_flags.gn && \
  # Keep cmdline-tools in the Chromium repo, remove mkdir command
  sed -i "s/^  rm -rf \"\$DIRECTORY\"/find \$DIRECTORY -mindepth 1 -maxdepth 1 -not -name cmdline-tools -exec rm -rf '{}' \\\;/" build.sh && \
  sed -i "s/^mkdir \"\${DIRECTORY}\" \&\& /" build.sh && \
  mkdir ../keystore && \
  echo -e 'android_keystore_name=""\nandroid_keystore_password=""\nandroid_keystore_path="//../../keystore/keystore.jks"\ntrichrome_certdigest=""' > ../keystore/keystore.gn && \
  echo > ../keystore/keystore.jks && \
  ./build.sh -a x86 -t chrome_modern_public_apk

# Copy APKs
RUN \
  cp -R ungoogled-chromium-android/src/out/Default/apks /