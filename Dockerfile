#
#  Based on: https://git.droidware.info/wchen342/ungoogled-chromium-android/src/branch/master/.github/workflows/build.yml
#

FROM archlinux:latest

# Install deps
RUN \
  sed -i "$(($(grep -n "\[multilib\]" /etc/pacman.conf | cut -f1 -d:) + 1))s/^#//g" /etc/pacman.conf && \
  pacman -Sy --noconfirm && \
  pacman -S --noconfirm --needed lib32-glibc multilib-devel gnu-free-fonts jdk8-openjdk base base-devel json-glib libva protobuf jsoncpp python python2 gperf wget rsync tar unzip curl gnupg maven yasm mesa npm ninja git clang lld gn llvm quilt && \
  # create /var/cache/pacman/pkg directory to prevent pacman -Scc generating
  # an error output about this missing directory
  mkdir /var/cache/pacman/pkg && \
  yes | pacman -Scc && \
  wget -q "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" && \
  echo "bfe34e1fa28d6d75a7ad05fd02fa5472275673d5f5621b77380898dee1be15d2 Miniconda3-latest-Linux-x86_64.sh" | sha256sum --check --status && \
  chmod +x Miniconda3-latest-Linux-x86_64.sh && \
  ./Miniconda3-latest-Linux-x86_64.sh -b -p ~/anaconda && rm -rf Miniconda3-latest-Linux-x86_64.sh && \
  source ~/anaconda/bin/activate && \
  conda init && \
  conda create -y --name py2 python=2 && \
  conda activate py2 && \
  pip install six

# Build
RUN \
  git clone https://git.droidware.info/wchen342/ungoogled-chromium-android.git && \
  cd ungoogled-chromium-android && \
  echo "use_egl=false" >> android_flags.gn && \
  mkdir ../keystore && \
  echo -e 'android_keystore_name=""\nandroid_keystore_password=""\nandroid_keystore_path="//../../keystore/keystore.jks"\ntrichrome_certdigest=""' > ../keystore/keystore.gn && \
  ./build.sh -a x86 -t chrome_modern_public_apk

# Copy APKs
RUN \
  cp -R ungoogled-chromium-android/src/out/Default/apks /