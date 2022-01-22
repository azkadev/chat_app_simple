# chat_app_simple With Socket Io Node js

https://user-images.githubusercontent.com/82513502/150629608-fe4c3418-e1af-492c-87a0-90c240b743e6.mp4

# CLone Repo

```bash
git clone https://github.com/azkadev/chat_app_simple.git
cd chat_app_simple
flutter pub get
```

## Build

1. CLone Repo

```bash
git clone https://github.com/azkadev/chat_app_simple.git
cd chat_app_simple
flutter pub get
```

2. Build App command

- Android
    ```bash
    flutter build android --release
    ```
- Linux
    ```bash
    flutter build linux --release
    ```

## Develop
open VSCode open folder chat_app_simple

1. connect your phone on your pc and open terminal

```bash
adb reverse tcp:3000 tcp:3000
```

2. start debugin on vscode with tap ```F5```

3. run server
open folder backend

```bash
npm install && node app
```