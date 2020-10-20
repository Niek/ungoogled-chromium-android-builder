# ungoogled-chromium-android-builder

This repo hosts a Dockerfile that builds the latest ungoogled-chromium APK for Android x86 devices without EGL.

To get the latest APK, run:
```bash
docker run -v $PWD:/mnt --rm niekvdmaas/ungoogled-chromium-android-builder cp -R /out /mnt
```