#
#  Based on: https://git.droidware.info/wchen342/ungoogled-chromium-android/src/branch/master/.github/workflows/build.yml
#

FROM archlinux:latest

ENV PACKAGES="lib32-glibc multilib-devel gnu-free-fonts jdk11-openjdk jdk8-openjdk base base-devel json-glib libva protobuf jsoncpp python python2 gperf wget rsync tar unzip curl gnupg maven yasm mesa npm ninja git clang lld llvm quilt"

# Install deps
RUN \
  set -x && \
  sed -i "$(($(grep -n "\[multilib\]" /etc/pacman.conf | cut -f1 -d:) + 1))s/^#//g" /etc/pacman.conf && \
  pacman -Syq --noconfirm && \
  pacman -Sq --noconfirm $PACKAGES && \
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
  git clone https://git.droidware.info/wchen342/ungoogled-chromium-android.git && \
  cd ungoogled-chromium-android && \
  # Skip trichrome APK
  echo > trichrome_generate_apk.sh && \
  # Speed up compiling
  #echo "use_egl=false" >> android_flags.gn && \
  echo -e "use_errorprone_java_compiler=false\ntreat_warnings_as_errors=false\ndisable_android_lint=true\nenable_nacl=false\nenable_swiftshader=true" >> android_flags.gn && \
  # Switch to default Android channel / FIXME: remove this, not necessary
  # Keep cmdline-tools in the Chromium repo, remove mkdir command
  sed -i "s/^  rm -rf \"\$DIRECTORY\"/find \$DIRECTORY -mindepth 1 -maxdepth 1 -not -name cmdline-tools -exec rm -rf '{}' \\\;/" build.sh && \
  sed -i "s/^mkdir \"\${DIRECTORY}\" \&\& //" build.sh && \
  mkdir ../keystore && \
  echo > ../keystore/keystore.gn && \
  #echo -e 'android_keystore_name=""\nandroid_keystore_password=""\nandroid_keystore_path="//../../keystore/keystore.jks"\ntrichrome_certdigest=""' > ../keystore/keystore.gn && \
  #echo > ../keystore/keystore.jks && \
  ./build.sh -a x86 -t chrome_modern_public_apk && \
  # Copy built APK files
  cp -R src/out/Default /out && \
  # Delete build dir
  rm -rf ../ungoogled-chromium-android && \
  # Remove all packages except base
  pacman -Rsu --noconfirm $PACKAGES && \
  pacman -Scc --noconfirm 