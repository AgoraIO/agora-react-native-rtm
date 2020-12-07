import React from 'react';
import PageContainer from '../components/page-container';
import { withNavigation } from 'react-navigation';
import { AppContext, AppContextType } from '../components/context';
import { GiftedChat } from 'react-native-gifted-chat';
import { Logger } from '../utils';

type ChatRoomState = {
  messages: any[];
  channel: string | any;
};

class ChatRoom extends React.Component<any, ChatRoomState, AppContextType> {
  static contextType = AppContext;
  context!: React.ContextType<typeof AppContext>;

  state: ChatRoomState = {
    messages: [],
    channel: null,
  };

  shouldComponentUpdate(nextProps: any) {
    return nextProps.navigation.isFocused();
  }

  subscribeChannelMessage() {
    this.context.client.on('error', (evt: any) => {
      Logger.log(evt);
    });

    this.context.client.on('channelMessageReceived', (evt: any) => {
      const { uid, channelId, text } = evt;
      console.log('evt', evt);
      Logger.log('channelMessageReceived uid ', uid);
      if (channelId === this.state.channel) {
        this.setState((prevState: ChatRoomState) => ({
          messages: GiftedChat.append(prevState.messages, [
            {
              _id: +new Date(),
              text,
              user: {
                _id: +new Date(),
                name: uid.substr(uid.length - 1, uid.length),
              },
              createdAt: new Date(),
            },
          ]),
        }));
        console.log('message from current channel', text);
      }
    });
  }

  onSend(messages: any[] = []) {
    const channel = this.state.channel;
    console.log('send channel', this.state.channel);
    messages.forEach((message: any) => {
      this.context.client
        .sendChannelMessage({
          channel,
          message: `${message.text}`,
        })
        .then(() => {
          console.log('send message');
          this.setState((prevState: ChatRoomState) => ({
            messages: GiftedChat.append(prevState.messages, [message]),
          }));
        })
        .catch(() => {
          console.warn('send failured');
        });
    });
  }

  componentDidMount() {
    let channel = this.props.navigation.getParam('channel', 'agora');
    console.log('mount chat ', channel);
    this.subscribeChannelMessage();
    this.context.client
      .join(channel)
      .then(() => {
        console.log('join channel success');
        this.setState({
          channel,
        });
      })
      .catch((_: any) => {
        console.warn('join failured');
      });
  }

  componentWillUnmount() {
    let channel = this.props.navigation.getParam('channel', 'agora');
    this.context.client.leave(channel);
  }

  render() {
    let uid = this.props.navigation.getParam('uid', '0');
    return (
      <GiftedChat
        messages={this.state.messages}
        onSend={(messages: any[]) => this.onSend(messages)}
        user={{
          _id: uid,
        }}
      />
    );
  }
}

export default PageContainer(withNavigation(ChatRoom));
