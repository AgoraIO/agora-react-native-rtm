# Agora RTM Example for React Native

*English | [中文](README.zh.md)*

This Tutorial will help you get agora-react-native-rtm integrated directly into your iOS/Android applications using with agora rtm sdk and react native.

With this sample app, you can:

- Join / Leave Channel
- Send / Receive Channel Messsages

## Prerequisites
- Agora.io [Developer Account](https://dashboard.agora.io/signin/)
- Xcode latest (10.0+)
- Android Studio latest
- nodejs LTS
- typescript
- cocoapods & android sdk & gradle plugin
- react-native (0.59.x)
- real mobile phone or emulator

## Quick Start

This section shows you how to prepare, build, and run the sample application.

### Obtain an App ID

To build and run the sample application, get an App ID:
1. Create a developer account at [agora.io](https://dashboard.agora.io/signin/). Once you finish the signup process, you will be redirected to the Dashboard.
2. Navigate in the Dashboard tree on the left to **Projects** > **Project List**.
3. Save the **App ID** from the Dashboard for later use.

### Update and Run the Sample Application
Open the project folder and edit the [`agora.config.json`](agora.config.json) file. Update `YOUR_APP_ID` with your app ID.

### Setup
#### Step 1. install node dependencies & link react native modules
Run the below commands in this project folder:
```bash
  npm install
  react-native link agora-react-native-rtm
  react-native link react-navigation
  react-native link react-native-gesture-handler
  react-native link react-native-vector-icons
```

#### Step 2. start react native package server
Once the build is complete, run the `npm run start` comamnd to start the package server.
```bash
  npm run start
```

#### Step 3. run in native platform

##### Android Platform

```bash
  react-native run-android
```

##### iOS Platform
  1. `cd ios; pod install`
  2. `open ios/chatsapp.xcworkspace`
  3. `fill with valid developer account identity & signing`
  4. `xcode build`


## Resources
* You can find full API document at [Document Center](https://docs.agora.io/en/)
* You can file bugs about this demo at [issue](https://github.com/AgoraIO/RN-SDK-RTM/issues)
* [React Native Getting Started](https://facebook.github.io/react-native/docs/getting-started.html)
* [agora-react-native-rtm docs](https://agoraio.github.io/RN-SDK-RTM/latest/)


## License

The MIT License (MIT)
