# ungoogled-chromium-android-builder

This repo hosts a Dockerfile that builds the latest ungoogled-chromium APK for Android x86 devices that works in emulators without hardware support.

To get the latest APK, run:
```bash
docker run -v $PWD:/mnt --rm niekvdmaas/ungoogled-chromium-android-builder cp -R /apks /mnt
```

If you want to build it yourself (note: this may take countless hours:
```bash
docker build . -t ungoogled-chromium-android-builder
```