# Agora RTM React Native 示例

*其他语言版本： [English](README.md)*

本教程将帮助您用react-native集成agora-react-native-rtm到您的iOS / Android设备中。

示例程序有如下功能：
  - 加入/离开频道
  - 发送/接收频道消息

## 准备工作
- Agora.io 账户[Developer Account](https://dashboard.agora.io/signin/)
- Xcode latest (10.0+)
- Android Studio latest
- nodejs LTS
- typescript
- cocoapods & android sdk & gradle plugin
- react-native (0.59.x)
- 手机设备，或者手机模拟器

## 快速开始

这一部分将向你展示如何准备，构建，执行这个示例程序。

### 创建一个帐户并获取一个App ID
要构建和运行示例应用程序，请首先获取Agora App ID：
1. 在[agora.io](https://dashboard.agora.io/signin/)创建开发人员帐户。完成注册过程后，您将被重定向到仪表板页面。
2. 在左侧的仪表板树中导航到**项目** > **项目列表**。
3. 将从仪表板获取的App ID复制到文本文件中。您将在启动应用程序时用到它。

### 更新并运行示例应用程序

打开[`agora.config.json`](agora.config.json)文件并添加App ID。

### 搭建步骤
#### 1. 安装项目依赖，链接RN模块
请在当前项目路径执行以下命令:

```bash
  npm install
  react-native link agora-react-native-rtm
  react-native link react-navigation
  react-native link react-native-gesture-handler
  react-native link react-native-vector-icons
```

#### 2. 执行npm run start
安装完成后，开始执行以下命令:

```bash
  npm run start
```

#### Step 3. 在原生平台上运行

##### 安卓平台:
```bash
  react-native run-android
```

##### iOS平台:
  1. `cd ios; pod install`
  2. `open ios/chatsapp.xcworkspace`
  3. `fill identity & signing'
  4. `xcode build`

## 附录
* Agora开发者中心[API 文档](https://docs.agora.io/cn/)
* [如果发现了示例代码的bug, 欢迎提交](https://github.com/AgoraIO-Community/Agora-RN-Quickstart/issues)
* [React Native入门教程](https://facebook.github.io/react-native/docs/getting-started.html)
* [agora-react-native-rtm SDK文档](https://agoraio.github.io/RN-SDK-RTM/latest/)

## License
MIT
