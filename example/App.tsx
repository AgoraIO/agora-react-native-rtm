/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * Generated with the TypeScript template
 * https://github.com/emin93/react-native-template-typescript
 *
 * @format
 */

import React from 'react';
import { createAppContainer, createStackNavigator } from 'react-navigation';
import Home from './src/pages';
import ChatRoom from './src/pages/chatroom';
import { AppContainer } from './src/components/context';
import { displayName as title } from './app.json';
import { Appbar } from 'react-native-paper';

const Toolbar = (_: any) => (
  <Appbar.Header>
    <Appbar.Action icon="menu" />
    <Appbar.Content title={title} />
  </Appbar.Header>
);

const AppNavigator = createStackNavigator(
  {
    Home: Home,
    Chats: ChatRoom,
  },
  {
    navigationOptions: (props: any) => ({
      title,
      gestureResponseDistance: {
        horizontal: 45,
      },
      header: <Toolbar {...props} />,
    }),
  }
);

const RootContainer = createAppContainer(AppNavigator);

export const App = () => {
  return (
    <AppContainer>
      <RootContainer />
    </AppContainer>
  );
};
