# ungoogled-chromium-android-builder

This repo hosts a Dockerfile that builds the latest ungoogled-chromium APK for Android x86 devices without EGL.

To pull, use:
```bash
docker pull niekvdmaas/ungoogled-chromium-android-builder
docker cp ungoogled-chromium-android-builder:/apks/* .
```