#
#  Based on: https://git.droidware.info/wchen342/ungoogled-chromium-android/src/branch/master/.github/workflows/build.yml
#

FROM archlinux:latest

ENV PACKAGES="lib32-glibc multilib-devel gnu-free-fonts jdk11-openjdk jdk8-openjdk base-devel json-glib libva protobuf jsoncpp python python2 gperf wget rsync tar unzip curl gnupg maven yasm mesa npm ninja git clang lld llvm quilt"

COPY buildflags.gn /tmp/
COPY disable-gl.patch /tmp/

# Install deps
RUN \
  set -x && \
  sed -i "$(($(grep -n "\[multilib\]" /etc/pacman.conf | cut -f1 -d:) + 1))s/^#//g" /etc/pacman.conf && \
  pacman -Syq --noconfirm && \
  pacman -Sq --noconfirm base $PACKAGES && \
  # Downgrade to older gn version, latest version doesn't work
  pacman -U --noconfirm https://archive.archlinux.org/packages/g/gn/gn-0.1731.5ed3c9cc-1-x86_64.pkg.tar.zst && \
  curl -s "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" -o Miniconda3-latest-Linux-x86_64.sh && \
  chmod +x Miniconda3-latest-Linux-x86_64.sh && \
  ./Miniconda3-latest-Linux-x86_64.sh -b -p ~/anaconda && \
  rm -rf Miniconda3-latest-Linux-x86_64.sh && \
  source ~/anaconda/bin/activate && \
  conda init && \
  conda create -y --name py2 python=2 && \
  conda activate py2 && \
  pip install six && \
  # Clone the ungoogled-chromium-android repo
  git clone https://git.droidware.info/wchen342/ungoogled-chromium-android.git && \
  cd ungoogled-chromium-android && \
  # Add patch to disable EGL
  echo "Other/disable-gl.patch" >> patches/series && \
  cp /tmp/disable-gl.patch patches/Other/ && \
  # Skip trichrome APK
  echo > trichrome_generate_apk.sh && \
  # Set appropriate GN build flags
  cat /tmp/buildflags.gn >> android_flags.gn && \
  # Keep cmdline-tools in the Chromium repo, remove mkdir command
  sed -i "s/^  rm -rf \"\$DIRECTORY\"/find \$DIRECTORY -mindepth 1 -maxdepth 1 -not -name cmdline-tools -exec rm -rf '{}' \\\;/" build.sh && \
  sed -i "s/^mkdir \"\${DIRECTORY}\" \&\& //" build.sh && \
  mkdir ../keystore && echo > ../keystore/keystore.gn && \
  # Build Chromium
  ./build.sh -a x86 -t chrome_modern_public_apk && \
  # Copy built APK files
  cp -R src/out/Default/apks /apks && \
  # Remove all packages except base
  pacman -Rsu --noconfirm $PACKAGES && \
  pacman -Scc --noconfirm && \
  # Remove all unnecessary files
  rm -rf ~/anaconda/ /var/cache/ /keystore/ /ungoogled-chromium-android/