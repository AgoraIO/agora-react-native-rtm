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

import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { Appbar } from 'react-native-paper';

import Home from './pages';
import ChatRoom from './pages/chatroom';
import { AppContainer } from './components/context';
import { displayName as title } from '../app.json';

const Toolbar = (_: any) => (
  <Appbar.Header>
    <Appbar.Action icon="menu" />
    <Appbar.Content title={title} />
  </Appbar.Header>
);

const Stack = createStackNavigator();

export default () => {
  return (
    <AppContainer>
      <NavigationContainer>
        <Stack.Navigator
          screenOptions={{
            title,
            gestureResponseDistance: {
              horizontal: 45,
            },
            header: (props) => <Toolbar {...props} />,
          }}
        >
          <Stack.Screen name={'Home'} component={Home} />
          <Stack.Screen name={'Chats'} component={ChatRoom} />
        </Stack.Navigator>
      </NavigationContainer>
    </AppContainer>
  );
};
