import { NativeEventEmitter, NativeModules } from 'react-native';

import {
  AgoraPeerMessage,
  Callback,
  ChannelAttributeOptions,
  ConnectionChangeReason,
  ConnectionState,
  Listener,
  ListPeerStatus,
  LocalInvitation,
  LocalInvitationError,
  LocalInvitationProps,
  LogLevel,
  Members,
  PeerOnlineState,
  PeersOnlineStatus,
  PeerSubscriptionOption,
  RemoteInvitation,
  RemoteInvitationError,
  RemoteInvitationProps,
  RtmAttribute,
  RtmChannelAttribute,
  RtmChannelMember,
  RTMChannelMessage,
  RtmConnectionState,
  RTMLocalInvitationErrorMessage,
  RTMLocalInvitationMessage,
  RTMMemberInfo,
  RtmMessage,
  RTMPeerMessage,
  RTMRemoteInvitationErrorMessage,
  RTMRemoteInvitationMessage,
  SendMessageOptions,
  Subscription,
  UserAttribute,
  UserInfo,
  UserProfile,
} from './types';

/**
 * @deprecated
 */
export interface RtmEngineEvents {
  /**
   * @deprecated
   * @event error
   * @param evt The received event object
   * error | occurs when wrapper emit error  | on("error") |
   */
  error: (evt: any) => void;

  /**
   * @deprecated {@link ConnectionStateChanged}
   * @event connectionStateChanged
   * @param evt The received event object {@link ConnectionState}
   * connectionStateChanged | occurs when connection state changed |
   */
  connectionStateChanged: (evt: ConnectionState) => void;

  /**
   * @deprecated {@link MessageReceived}
   * @event messageReceived
   * @param evt The received event object {@link RTMPeerMessage}
   * messageReceived | occurs when message received |
   */
  messageReceived: (evt: RTMPeerMessage) => void;

  /**
   * @deprecated {@link TokenExpired}
   * @event tokenExpired
   * @param evt The received event object
   * tokenExpired | occurs when token has expired |
   */
  tokenExpired: (evt: any) => void;

  /**
   * @deprecated {@link ChannelMessageReceived}
   * @event channelMessageReceived
   * @param evt The received event object {@link RTMChannelMessage}
   * channelMessageReceived | occurs when received channel message |
   */
  channelMessageReceived: (evt: RTMChannelMessage) => void;

  /**
   * @deprecated {@link ChannelMemberJoined}
   * @event channelMemberJoined
   * @param evt The received event object {@link RTMMemberInfo}
   * channelMemberJoined | occurs when some one joined in the subscribed channel
   */
  channelMemberJoined: (evt: RTMMemberInfo) => void;

  /**
   * @deprecated {@link ChannelMemberLeft}
   * @event channelMemberLeft
   * @param evt The received event object {@link RTMMemberInfo}
   * channelMemberLeft | occurs when sone one left from u subscribed channel
   */
  channelMemberLeft: (evt: RTMMemberInfo) => void;

  /**
   * @deprecated {@link LocalInvitationReceivedByPeer}
   * @event localInvitationReceivedByPeer
   * @param evt The received event object {@link RTMLocalInvitationMessage}
   * localInvitationReceivedByPeer | occurs when local inviation received by peer |
   */
  localInvitationReceivedByPeer: (evt: RTMLocalInvitationMessage) => void;

  /**
   * @deprecated {@link LocalInvitationAccepted}
   * @event localInvitationAccepted
   * @param evt The received event object {@link RTMLocalInvitationMessage}
   * localInvitationAccepted | occurs when local invitation accepted |
   */
  localInvitationAccepted: (evt: RTMLocalInvitationMessage) => void;

  /**
   * @deprecated {@link LocalInvitationRefused}
   * @event localInvitationRefused
   * @param evt The received event object {@link RTMLocalInvitationMessage}
   * localInvitationRefused | occurs when local invitation refused |
   */
  localInvitationRefused: (evt: RTMLocalInvitationMessage) => void;

  /**
   * @deprecated {@link LocalInvitationCanceled}
   * @event localInvitationCanceled
   * @param evt The received event object {@link RTMLocalInvitationMessage}
   * localInvitationCanceled | occurs when local invitation canceled |
   */
  localInvitationCanceled: (evt: RTMLocalInvitationMessage) => void;

  /**
   * @deprecated {@link LocalInvitationFailure}
   * @event localInvitationFailure
   * @param evt The received event object {@link RTMLocalInvitationErrorMessage}
   * localInvitationFailure | occurs when local invitation failure |
   */
  localInvitationFailure: (evt: RTMLocalInvitationErrorMessage) => void;

  /**
   * @deprecated {@link RemoteInvitationReceived}
   * @event remoteInvitationReceived
   * @param evt The received event object {@link RTMRemoteInvitationMessage}
   * remoteInvitationReceived | occurs when remote invitation received |
   */
  remoteInvitationReceived: (evt: RTMRemoteInvitationMessage) => void;

  /**
   * @deprecated {@link RemoteInvitationAccepted}
   * @event remoteInvitationAccepted
   * @param evt The received event object {@link RTMRemoteInvitationMessage}
   * remoteInvitationAccepted | occurs when remote invitation accepted |
   */
  remoteInvitationAccepted: (evt: RTMRemoteInvitationMessage) => void;

  /**
   * @deprecated {@link RemoteInvitationRefused}
   * @event remoteInvitationRefused
   * @param evt The received event object {@link RTMRemoteInvitationMessage}
   * remoteInvitationRefused | occurs when remote invitation refused |
   */
  remoteInvitationRefused: (evt: RTMRemoteInvitationMessage) => void;

  /**
   * @deprecated {@link RemoteInvitationCanceled}
   * @event remoteInvitationCanceled
   * @param evt The received event object {@link RTMRemoteInvitationMessage}
   * remoteInvitationCanceled | occurs when remote invitation canceled |
   */
  remoteInvitationCanceled: (evt: RTMRemoteInvitationMessage) => void;

  /**
   * @deprecated {@link RemoteInvitationFailure}
   * @event remoteInvitationFailure
   * @param evt The received event object {@link RTMRemoteInvitationErrorMessage}
   * remoteInvitationFailure | occurs when remote invitation failure |
   */
  remoteInvitationFailure: (evt: RTMRemoteInvitationErrorMessage) => void;
}

export interface RtmClientEvents {
  ConnectionStateChanged: (
    state: RtmConnectionState,
    reason: ConnectionChangeReason
  ) => void;

  MessageReceived: (message: RtmMessage, peerId: string) => void;

  TokenExpired: () => void;

  PeersOnlineStatusChanged: (peersStatus: PeersOnlineStatus) => void;

  MemberCountUpdated: (memberCount: number) => void;

  ChannelAttributesUpdated: (attributeList: RtmChannelAttribute[]) => void;

  ChannelMessageReceived: (
    message: RtmMessage,
    fromMember: RtmChannelMember
  ) => void;

  ChannelMemberJoined: (member: RtmChannelMember) => void;

  ChannelMemberLeft: (member: RtmChannelMember) => void;

  LocalInvitationReceivedByPeer: (localInvitation: LocalInvitation) => void;

  LocalInvitationAccepted: (
    localInvitation: LocalInvitation,
    response?: string
  ) => void;

  LocalInvitationRefused: (
    localInvitation: LocalInvitation,
    response?: string
  ) => void;

  LocalInvitationCanceled: (localInvitation: LocalInvitation) => void;

  LocalInvitationFailure: (
    localInvitation: LocalInvitation,
    errorCode: LocalInvitationError
  ) => void;

  RemoteInvitationReceived: (remoteInvitation: RemoteInvitation) => void;

  RemoteInvitationAccepted: (remoteInvitation: RemoteInvitation) => void;

  RemoteInvitationRefused: (remoteInvitation: RemoteInvitation) => void;

  RemoteInvitationCanceled: (remoteInvitation: RemoteInvitation) => void;

  RemoteInvitationFailure: (
    remoteInvitation: RemoteInvitation,
    errorCode: RemoteInvitationError
  ) => void;
}

const {
  /**
   * @ignore
   */
  AgoraRTM,
} = NativeModules;
/**
 * @ignore
 */
const Prefix = AgoraRTM.prefix;
/**
 * @ignore
 */
const RtmClientEvent = new NativeEventEmitter(AgoraRTM);

/**
 * `RtmEngine` is the entry point of the react native agora rtm sdk. You can call the {@link createClient} method of {@link RtmEngine} to create an `RtmEngine` instance.
 * @noInheritDoc
 */
export default class RtmEngine {
  /**
   * @ignore
   */
  private _listeners = new Map<string, Map<Listener, Listener>>();

  /**
   * @deprecated {@link addListener}
   * supports platform: ios, android
   * @events {@link RtmEngineEvents}
   * @param eventName string required
   * @param callback (evt) => {} required
   */
  on<EventName extends keyof RtmEngineEvents>(
    eventName: EventName,
    callback: RtmEngineEvents[EventName]
  ) {
    switch (eventName) {
      case 'tokenExpired':
        this.addListener('TokenExpired', () => {
          callback(undefined);
        });
        break;
      case 'remoteInvitationRefused':
        this.addListener('RemoteInvitationRefused', (remoteInvitation) => {
          const ret: RTMRemoteInvitationMessage = { ...remoteInvitation };
          callback(ret);
        });
        break;
      case 'remoteInvitationFailure':
        this.addListener(
          'RemoteInvitationFailure',
          (remoteInvitation, errorCode) => {
            const ret: RTMRemoteInvitationErrorMessage = {
              ...remoteInvitation,
              code: errorCode,
            };
            callback(ret);
          }
        );
        break;
      case 'remoteInvitationCanceled':
        this.addListener('RemoteInvitationCanceled', (remoteInvitation) => {
          const ret: RTMRemoteInvitationMessage = { ...remoteInvitation };
          callback(ret);
        });
        break;
      case 'remoteInvitationAccepted':
        this.addListener('RemoteInvitationAccepted', (remoteInvitation) => {
          const ret: RTMRemoteInvitationMessage = { ...remoteInvitation };
          callback(ret);
        });
        break;
      case 'messageReceived':
        this.addListener('MessageReceived', (message, peerId) => {
          const ret: RTMPeerMessage = {
            text: message.text,
            ts: message.serverReceivedTs?.toString(),
            offline: message.isOfflineMessage,
            peerId,
          };
          callback(ret);
        });
        break;
      case 'localInvitationRefused':
        this.addListener('LocalInvitationRefused', (localInvitation) => {
          const ret: RTMLocalInvitationMessage = { ...localInvitation };
          callback(ret);
        });
        break;
      case 'localInvitationReceivedByPeer':
        this.addListener('LocalInvitationReceivedByPeer', (localInvitation) => {
          const ret: RTMLocalInvitationMessage = { ...localInvitation };
          callback(ret);
        });
        break;
      case 'localInvitationFailure':
        this.addListener(
          'LocalInvitationFailure',
          (localInvitation, errorCode) => {
            const ret: RTMLocalInvitationErrorMessage = {
              ...localInvitation,
              code: errorCode,
            };
            callback(ret);
          }
        );
        break;
      case 'localInvitationCanceled':
        this.addListener('LocalInvitationCanceled', (localInvitation) => {
          const ret: RTMLocalInvitationMessage = { ...localInvitation };
          callback(ret);
        });
        break;
      case 'localInvitationAccepted':
        this.addListener('LocalInvitationAccepted', (localInvitation) => {
          const ret: RTMLocalInvitationMessage = { ...localInvitation };
          callback(ret);
        });
        break;
      case 'error':
        console.warn('deprecated');
        break;
      case 'connectionStateChanged':
        this.addListener('ConnectionStateChanged', (state, reason) => {
          const ret: ConnectionState = { reason, state };
          callback(ret);
        });
        break;
      case 'channelMessageReceived':
        this.addListener('ChannelMessageReceived', (message, fromMember) => {
          const ret: RTMChannelMessage = {
            channelId: fromMember.channelId,
            offline: message.isOfflineMessage,
            text: message.text,
            ts: message.serverReceivedTs?.toString(),
            uid: fromMember.userId,
          };
          callback(ret);
        });
        break;
      case 'channelMemberLeft':
        this.addListener('ChannelMemberLeft', (member) => {
          const ret: RTMMemberInfo = {
            channelId: member.channelId,
            uid: member.userId,
          };
          callback(ret);
        });
        break;
      case 'channelMemberJoined':
        this.addListener('ChannelMemberJoined', (member) => {
          const ret: RTMMemberInfo = {
            channelId: member.channelId,
            uid: member.userId,
          };
          callback(ret);
        });
        break;
      case 'remoteInvitationReceived':
        this.addListener('RemoteInvitationReceived', (remoteInvitation) => {
          const ret: RTMRemoteInvitationMessage = { ...remoteInvitation };
          callback(ret);
        });
        break;
    }
  }

  /**
   * @deprecated {@link removeAllListeners}
   */
  removeEvents() {
    this.removeAllListeners();
  }

  addListener<EventType extends keyof RtmClientEvents>(
    event: EventType,
    listener: RtmClientEvents[EventType]
  ): Subscription {
    const callback = (res: any) => {
      // @ts-ignore
      listener(...res);
    };
    let map = this._listeners.get(event);
    if (map === undefined) {
      map = new Map<Listener, Listener>();
      this._listeners.set(event, map);
    }
    RtmClientEvent.addListener(Prefix + event, callback);
    map.set(listener, callback);
    return {
      remove: () => {
        this.removeListener(event, listener);
      },
    };
  }

  removeListener<EventType extends keyof RtmClientEvents>(
    event: EventType,
    listener: RtmClientEvents[EventType]
  ) {
    const map = this._listeners.get(event);
    if (map === undefined) return;
    RtmClientEvent.removeListener(
      Prefix + event,
      map.get(listener) as Listener
    );
    map.delete(listener);
  }

  removeAllListeners<EventType extends keyof RtmClientEvents>(
    event?: EventType
  ) {
    if (event === undefined) {
      this._listeners.forEach((_, key) => {
        RtmClientEvent.removeAllListeners(Prefix + key);
      });
      this._listeners.clear();
      return;
    }
    RtmClientEvent.removeAllListeners(Prefix + event);
    this._listeners.delete(event as string);
  }

  /**
   * @deprecated {@link release}
   * supports platform: ios, android
   * This method destroy AgoraRTM instance, stop event observing, release all both remote and local invitaitons and channels resources.
   * @return void
   */
  destroyClient(): Promise<void> {
    return this.release();
  }

  async release(): Promise<void> {
    this.removeAllListeners();
    await AgoraRTM.destroy();
  }

  /**
   * @deprecated {@link loginV2}
   * supports platform: ios, android
   * This method do login with UserInfo
   * @param params {@link UserInfo}
   * ---
   * token | string | optional |
   * uid | string | required |
   * ---
   * @return Promise<void>
   */
  login(params: UserInfo): Promise<void> {
    return this.loginV2(params.uid, params.token);
  }

  loginV2(userId: string, token?: string): Promise<void> {
    return AgoraRTM.login({ token, userId });
  }

  /**
   * supports platform: ios, android
   * This method do logout.
   * @return Promise<void>
   */
  logout(): Promise<void> {
    return AgoraRTM.logout();
  }

  /**
   * @deprecated {@link sendMessageToPeerV2}
   * supports platform: ios, android
   * This method do send p2p message with {@link AgoraPeerMessage}
   * @param params AgoraPeerMessage
   * ---
   * peerId | string | required |
   * offline | boolean | requried |
   * text | string | required |
   * ---
   * @return Promise<void>
   */
  sendMessageToPeer(params: AgoraPeerMessage): Promise<void> {
    return this.sendMessageToPeerV2(
      params.peerId,
      new RtmMessage(params.text),
      { enableOfflineMessaging: params.offline }
    );
  }

  sendMessageToPeerV2(
    peerId: string,
    message: RtmMessage,
    options: SendMessageOptions
  ): Promise<void> {
    return AgoraRTM.sendMessageToPeer({ peerId, message, options });
  }

  /**
   * @deprecated {@link queryPeersOnlineStatusV2}
   * supports platform: ios, android
   * This method enables query peer online user by id array.
   * @param ids string array
   * @return Promise<ListPeerStatus> {@link ListPeerStatus}
   * ---
   * items | {@link MemberStatus} |
   * ---
   *
   * MemberStatus
   * ---
   * uid | string | user id|
   * online | boolean | online state|
   * ---
   */
  queryPeersOnlineStatus(ids: string[]): Promise<ListPeerStatus> {
    return this.queryPeersOnlineStatusV2(ids).then((res) => {
      return {
        items: Object.entries(res).map((value) => {
          return { uid: value[0], online: value[1] === PeerOnlineState.ONLINE };
        }),
      };
    });
  }

  queryPeersOnlineStatusV2(peerIds: string[]): Promise<PeersOnlineStatus> {
    return AgoraRTM.queryPeersOnlineStatus({ peerIds });
  }

  subscribePeersOnlineStatus(peerIds: string[]): Promise<void> {
    return AgoraRTM.subscribePeersOnlineStatus({ peerIds });
  }

  unsubscribePeersOnlineStatus(peerIds: string[]): Promise<void> {
    return AgoraRTM.unsubscribePeersOnlineStatus({ peerIds });
  }

  queryPeersBySubscriptionOption(
    option: PeerSubscriptionOption
  ): Promise<string[]> {
    return AgoraRTM.queryPeersBySubscriptionOption({ option });
  }

  /**
   * supports platform: ios, android
   * This method do renewToken when got `tokenExpired` event.
   * @param token string
   * @return Promise<void>
   */
  renewToken(token: string): Promise<void> {
    return AgoraRTM.renewToken({ token });
  }

  /**
   * @deprecated {@link setLocalUserAttributesV2}
   * supports platform: ios, android
   * This method enables set local user attributes with attributes {@link UserAttribute}
   * @param attributes {@link UserAttribute []}
   * @return Promise<void>
   *
   * UserAttribute
   * ---
   * key | string | required |
   * value | string | required |
   * ---
   */
  setLocalUserAttributes(attributes: UserAttribute[]): Promise<void> {
    return this.setLocalUserAttributesV2(attributes);
  }

  setLocalUserAttributesV2(attributes: RtmAttribute[]): Promise<void> {
    return AgoraRTM.setLocalUserAttributes({ attributes });
  }

  /**
   * @deprecated {@link addOrUpdateLocalUserAttributes}
   * supports platform: ios, android
   * This method enables you to replace attribute already exists or add attribute wasn't set for local user attributes;
   * @param attributes {@link UserAttribute []}
   * @return Promise<void>
   */
  replaceLocalUserAttributes(attributes: UserAttribute[]): Promise<void> {
    return this.addOrUpdateLocalUserAttributes(attributes);
  }

  addOrUpdateLocalUserAttributes(attributes: RtmAttribute[]): Promise<void> {
    return AgoraRTM.addOrUpdateLocalUserAttributes({ attributes });
  }

  /**
   * @deprecated {@link deleteLocalUserAttributesByKeys}
   * supports platform: ios, android
   * This method enables you to remove exists attribute for local user.
   * @param keys string []
   * @return Promise<void>
   */
  removeLocalUserAttributesByKeys(keys: string[]): Promise<void> {
    return this.deleteLocalUserAttributesByKeys(keys);
  }

  deleteLocalUserAttributesByKeys(attributeKeys: string[]): Promise<void> {
    return AgoraRTM.deleteLocalUserAttributesByKeys({ attributeKeys });
  }

  /**
   * @deprecated {@link clearLocalUserAttributes}
   * supports platform: ios, android
   * This method enables you to remove all of local user attributes;
   * @return Promise<void>
   */
  removeAllLocalUserAttributes(): Promise<void> {
    return this.clearLocalUserAttributes();
  }

  clearLocalUserAttributes(): Promise<void> {
    return AgoraRTM.clearLocalUserAttributes();
  }

  /**
   * @deprecated {@link getUserAttributes}
   * supports platform: ios, android
   * This method enables you get user attributes by uid.
   * @param uid string. user id
   * @return Promise<UserProfile> {@link UserProfile}
   */
  getUserAttributesByUid(uid: string): Promise<UserProfile> {
    return this.getUserAttributes(uid).then((res: RtmAttribute[]) => {
      let ret: any = {};
      res.forEach((value) => {
        ret[value.key] = value.value;
      });
      return { uid, attributes: ret };
    });
  }

  getUserAttributes(userId: string): Promise<RtmAttribute[]> {
    return AgoraRTM.getUserAttributes({ userId });
  }

  getUserAttributesByKeys(
    userId: string,
    attributeKeys: string[]
  ): Promise<RtmAttribute[]> {
    return AgoraRTM.getUserAttributesByKeys({ userId, attributeKeys });
  }

  setChannelAttributes(
    channelId: string,
    attributes: RtmChannelAttribute[],
    option: ChannelAttributeOptions
  ): Promise<void> {
    return AgoraRTM.setChannelAttributes({ channelId, attributes, option });
  }

  addOrUpdateChannelAttributes(
    channelId: string,
    attributes: RtmChannelAttribute[],
    option: ChannelAttributeOptions
  ): Promise<void> {
    return AgoraRTM.addOrUpdateChannelAttributes({
      channelId,
      attributes,
      option,
    });
  }

  deleteChannelAttributesByKeys(
    channelId: string,
    attributeKeys: string[],
    option: ChannelAttributeOptions
  ): Promise<void> {
    return AgoraRTM.deleteChannelAttributesByKeys({
      channelId,
      attributeKeys,
      option,
    });
  }

  clearChannelAttributes(
    channelId: string,
    option: ChannelAttributeOptions
  ): Promise<void> {
    return AgoraRTM.clearChannelAttributes({ channelId, option });
  }

  getChannelAttributes(channelId: string): Promise<RtmChannelAttribute[]> {
    return AgoraRTM.getChannelAttributes({ channelId });
  }

  getChannelAttributesByKeys(
    channelId: string,
    attributeKeys: string[]
  ): Promise<RtmChannelAttribute[]> {
    return AgoraRTM.getChannelAttributesByKeys({ channelId, attributeKeys });
  }

  setParameters(parameters: string): Promise<void> {
    return AgoraRTM.setParameters({ parameters });
  }

  /**
   * @deprecated {@link setLogFile} {@link setLogFilter} {@link setLogFileSize}
   * set sdk log file
   * @param path string: specified the generated log path
   * @param level {@link LogLevel}: sdk log level (0: "OFF", 0x0f: "INFO", 0x0e: "WARN", 0x0c: "ERROR", 0x08: "CRITICAL")
   * @param size number: file size in kbytes
   * Note File size settings of less than 512 KB or greater than 10 MB will not take effect.
   * @return Promise<void> This method will return {path: boolean, level: boolean, size: boolean}
   */
  async setSdkLog(path: string, level: LogLevel, size: number): Promise<void> {
    await this.setLogFile(path);
    await this.setLogFilter(level);
    await this.setLogFileSize(size);
  }

  setLogFile(filePath: string): Promise<void> {
    return AgoraRTM.setLogFile({ filePath });
  }

  setLogFilter(filter: LogLevel): Promise<void> {
    return AgoraRTM.setLogFilter({ filter });
  }

  setLogFileSize(fileSizeInKBytes: number): Promise<void> {
    return AgoraRTM.setLogFileSize({ fileSizeInKBytes });
  }

  /**
   * @deprecated {@link createInstance}
   * supports platform: ios, android
   * This method creates AgoraRTM instance and begin event observing, collect all both remote and local invitations and channels resources.
   * method: createClient
   * @param appId string
   * @return void
   */
  async createClient(appId: string): Promise<void> {
    return this.createInstance(appId);
  }

  async createInstance(appId: string): Promise<void> {
    await AgoraRTM.createInstance(appId);
  }

  /**
   * @deprecated
   * get the version of rtm sdk
   * @param callback (version) => {} required
   */
  getSdkVersion(callback: Callback): void {
    RtmEngine.getSdkVersion().then((res) => {
      // @ts-ignore
      callback(res);
    });
  }

  static getSdkVersion(): Promise<string> {
    return AgoraRTM.getSdkVersion();
  }

  /**
   * supports platform: ios, android
   * This method do join channel with channelId
   * @param channelId string
   * @return Promise<void>
   */
  joinChannel(channelId: string): Promise<void> {
    return AgoraRTM.joinChannel({ channelId });
  }

  /**
   * supports platform: ios, android
   * This method do leave channel with channelId
   * @param channelId string
   * @return Promise<void>
   */
  leaveChannel(channelId: string): Promise<void> {
    return AgoraRTM.leaveChannel({ channelId });
  }

  /**
   * @deprecated {@link sendMessage}
   * supports platform: ios, android
   * This method enables send message by channel id.
   * NOTICE: text bytelength has MAX_SIZE 32kb limit.
   * @param channelId string.
   * @param text string (bytesize shouldn't >= 32kb)
   * @return Promise<void>
   */
  sendMessageByChannelId(channelId: string, text: string): Promise<void> {
    return this.sendMessage(channelId, new RtmMessage(text), {});
  }

  sendMessage(
    channelId: string,
    message: RtmMessage,
    options: SendMessageOptions
  ): Promise<void> {
    return AgoraRTM.sendMessage({ channelId, message, options });
  }

  /**
   * @deprecated {@link getMembers}
   * supports platform: ios, android
   * This method enables you get members by channel id.
   * @param channelId string.
   * @return Promise<Members> {@link Members}}
   *
   * ---
   * members | {@link MemberInfo} |
   * ---
   *
   * MemberInfo
   * ---
   * uid | string | user id|
   * channelId | string | channel id|
   * ---
   */
  getChannelMembersBychannelId(channelId: string): Promise<Members> {
    return this.getMembers(channelId).then((res) => {
      return {
        members: res.map((value) => {
          return { uid: value.userId, channelId };
        }),
      };
    });
  }

  getMembers(channelId: string): Promise<RtmChannelMember[]> {
    return AgoraRTM.getMembers({ channelId });
  }

  releaseChannel(channelId: string): Promise<void> {
    return AgoraRTM.releaseChannel({ channelId });
  }

  createLocalInvitation(
    calleeId: string,
    content?: string,
    channelId?: string
  ): Promise<LocalInvitation> {
    return AgoraRTM.createLocalInvitation({ calleeId, content, channelId });
  }

  /**
   * @deprecated {@link sendLocalInvitationV2}
   * supports platform: ios, android
   * This method enables send local invitation with invitationProps.
   * NOTICE: content bytelength has MAX_SIZE 32kb limit.
   * @param invitationProps {@link LocalInvitationProps}
   *
   * LocalInvitationProps
   * ---
   * uid | string | required |
   * channelId | string | required |
   * content | string | optional | 32kb limit |
   * ---
   *
   * @return Promise<void>
   */
  async sendLocalInvitation(
    invitationProps: LocalInvitationProps
  ): Promise<void> {
    return this.sendLocalInvitationV2(
      await this.createLocalInvitation(
        invitationProps.uid,
        invitationProps.content,
        invitationProps.channelId
      )
    );
  }

  sendLocalInvitationV2(localInvitation: LocalInvitation): Promise<void> {
    return AgoraRTM.sendLocalInvitation({ localInvitation });
  }

  /**
   * @deprecated {@link acceptRemoteInvitationV2}
   * supports platform: ios, android
   * This method enables accept remote invitation with RemoteInvitationProps.
   * NOTICE: content bytelength has MAX_SIZE 32kb limit.
   * @param remoteInvitationProps {@link RemoteInvitationProps}
   *
   * RemoteInvitationProps
   * ---
   * uid | string | required |
   * channelId | string | required |
   * response | string | optional | 32kb limit |
   * ---
   *
   * @return Promise<void>
   */
  acceptRemoteInvitation(
    remoteInvitationProps: RemoteInvitationProps
  ): Promise<void> {
    return this.acceptRemoteInvitationV2({
      callerId: remoteInvitationProps.uid,
      response: remoteInvitationProps.response,
      channelId: remoteInvitationProps.channelId,
      hash: 0,
    });
  }

  acceptRemoteInvitationV2(remoteInvitation: RemoteInvitation): Promise<void> {
    return AgoraRTM.acceptRemoteInvitation({ remoteInvitation });
  }

  /**
   * @deprecated {@link refuseRemoteInvitationV2}
   * supports platform: ios, android
   * This method enables refuse remote invitation with RemoteInvitationProps.
   * NOTICE: content bytelength has MAX_SIZE 32kb limit.
   * @param remoteInvitationProps {@link RemoteInvitationProps}
   *
   * RemoteInvitationProps
   * ---
   * uid | string | required |
   * channelId | string | required |
   * response | string | optional | 32kb limit |
   * ---
   *
   * @return Promise<void>
   */
  refuseRemoteInvitation(
    remoteInvitationProps: RemoteInvitationProps
  ): Promise<void> {
    return this.refuseRemoteInvitationV2({
      callerId: remoteInvitationProps.uid,
      response: remoteInvitationProps.response,
      channelId: remoteInvitationProps.channelId,
      hash: 0,
    });
  }

  refuseRemoteInvitationV2(remoteInvitation: RemoteInvitation): Promise<void> {
    return AgoraRTM.refuseRemoteInvitation({ remoteInvitation });
  }

  /**
   * @deprecated {@link cancelLocalInvitationV2}
   * supports platform: ios, android
   * This method enables cancel local invitation with invitationProps.
   * NOTICE: content bytelength has MAX_SIZE 32kb limit.
   * @param invitationProps {@link LocalInvitationProps}
   *
   * LocalInvitationProps
   * ---
   * uid | string | required |
   * channelId | string | required |
   * content | string | optional | 32kb limit |
   * ---
   *
   * @return Promies<any>
   */
  cancelLocalInvitation(invitationProps: LocalInvitationProps): Promise<void> {
    return this.cancelLocalInvitationV2({
      calleeId: invitationProps.uid,
      content: invitationProps.content,
      channelId: invitationProps.channelId,
      hash: 0,
    });
  }

  cancelLocalInvitationV2(localInvitation: LocalInvitation): Promise<void> {
    return AgoraRTM.cancelLocalInvitation({ localInvitation });
  }
}
