import RtmEngine from 'agora-react-native-rtm';
import { EventEmitter } from 'events';
import { Logger } from './utils';

const config = require('../agora.config.json');

export default class RtmAdapter extends EventEmitter {
  private readonly client: RtmEngine;
  public uid: string | any;

  constructor() {
    super();
    this.uid = null;
    this.client = new RtmEngine();
    const events = [
      'tokenExpired',
      'remoteInvitationRefused',
      'remoteInvitationFailure',
      'remoteInvitationCanceled',
      'remoteInvitationAccepted',
      'messageReceived',
      'localInvitationRefused',
      'localInvitationReceivedByPeer',
      'localInvitationFailure',
      'localInvitationCanceled',
      'localInvitationAccepted',
      'error',
      'connectionStateChanged',
      'channelMessageReceived',
      'channelMemberLeft',
      'channelMemberJoined',
      'remoteInvitationReceived',
    ];
    events.forEach((event: string) => {
      // @ts-ignore
      this.client.on(event, (evt: any) => {
        console.warn(event, evt);
        this.emit(event, evt);
      });
    });
  }

  async login(uid: string): Promise<any> {
    await this.client.createClient(config.appId);
    this.uid = uid;
    return this.client.login({
      uid: this.uid,
      token: config.token,
    });
  }

  async logout(): Promise<any> {
    await this.client.logout();
    Logger.log('logout success');
  }

  async join(cid: string): Promise<any> {
    return this.client.joinChannel(cid);
  }

  async leave(cid: string): Promise<any> {
    return this.client.leaveChannel(cid);
  }

  async sendChannelMessage(param: {
    channel: string;
    message: string;
  }): Promise<any> {
    return this.client.sendMessageByChannelId(param.channel, param.message);
  }

  async destroy(): Promise<any> {
    await this.client.destroyClient();
    Logger.log('destroy');
  }
}
