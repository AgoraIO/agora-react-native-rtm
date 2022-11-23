import React from 'react';
import {
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  StyleSheet,
} from 'react-native';
import { Button, TextInput } from 'react-native-paper';

import PageContainer from '../components/page-container';
import { AppContext, AppContextType } from '../components/context';

interface HomeState {
  uid: string;
  channel: string;
  login: boolean;
}

class Home extends React.Component<any, HomeState, AppContextType> {
  static contextType = AppContext;
  declare context: React.ContextType<typeof AppContext>;

  constructor(props: any) {
    super(props);
    this.state = {
      uid: 'test',
      channel: '',
      login: false,
    };
    this.onJoin = this.onJoin.bind(this);
  }

  componentWillUnmount() {
    this.context.client.logout();
    this.context.client.destroy();
  }

  onLogin() {
    this.context.client.login(this.state.uid).then(() => {
      this.setState({
        login: true,
      });
    });
  }

  onJoin() {
    this.context.setChannel(this.state.channel);
    this.props.navigation.push('Chats', { channel: this.state.channel });
  }

  render() {
    return (
      <KeyboardAvoidingView
        style={styles.wrapper}
        keyboardVerticalOffset={Platform.select({
          ios: 0,
          android: 64,
        })}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView
          style={[styles.container]}
          keyboardShouldPersistTaps={'always'}
          removeClippedSubviews={false}
        >
          <TextInput
            style={styles.inputContainerStyle}
            label="uid"
            value={this.state.uid}
            onChangeText={(text: string) => this.setState({ uid: text })}
          />
          <Button
            style={styles.buttonContainerStyle}
            onPress={() => {
              this.onLogin();
            }}
          >
            login
          </Button>
          <TextInput
            style={styles.inputContainerStyle}
            label="channel name"
            value={this.state.channel}
            onChangeText={(text: string) => this.setState({ channel: text })}
          />
          <Button
            style={styles.buttonContainerStyle}
            onPress={() => {
              this.onJoin();
            }}
          >
            join channel
          </Button>
        </ScrollView>
      </KeyboardAvoidingView>
    );
  }
}

const styles = StyleSheet.create({
  colors: {
    backgroundColor: '#6200ee',
  },
  container: {
    backgroundColor: '#F5FCFF',
    flex: 1,
    flexDirection: 'column',
  },
  wrapper: {
    flex: 1,
  },
  inputContainerStyle: {
    margin: 8,
    flex: 2,
  },
  buttonContainerStyle: {
    flex: 2,
  },
  contenStyle: {
    textAlign: 'center',
  },
});

export default PageContainer(Home);
