import React from 'react';
import { GiftedChat } from 'react-native-gifted-chat';

import PageContainer from '../components/page-container';
import { AppContext, AppContextType } from '../components/context';
import { Logger } from '../utils';

type ChatRoomState = {
  messages: any[];
  channel: string | any;
};

class ChatRoom extends React.Component<any, ChatRoomState, AppContextType> {
  static contextType = AppContext;
  declare context: React.ContextType<typeof AppContext>;

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
    const { channel } = this.props.route.params;
    const channelId = channel === '' ? 'agora' : channel;
    console.log('mount chat', channelId);
    this.subscribeChannelMessage();
    this.context.client
      .join(channelId)
      .then(() => {
        console.log('join channel success');
        this.setState({
          channel: channelId,
        });
      })
      .catch((_: any) => {
        console.warn('join failured');
      });
  }

  componentWillUnmount() {
    const { channel } = this.props.route.params;
    const channelId = channel === '' ? 'agora' : channel;
    this.context.client.leave(channelId);
  }

  render() {
    const { uid } = this.props.route.params;
    let userId = uid === '' ? '0' : uid;
    return (
      <GiftedChat
        wrapInSafeArea={false}
        messages={this.state.messages}
        onSend={(messages: any[]) => this.onSend(messages)}
        user={{
          _id: userId,
        }}
      />
    );
  }
}

export default PageContainer(ChatRoom);
