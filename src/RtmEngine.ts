import {
  RTMEventCallback,
  Callback,
  UserInfo,
  AgoraPeerMessage,
  UserAttribute,
  LocalInvitationProps,
  RemoteInvitationProps,
  Members,
  ListPeerStatus,
  UserProfile,
  ConnectionState,
  RTMLocalInvitationMessage,
  RTMLocalInvitationErrorMessage,
  RTMRemoteInvitationErrorMessage,
  RTMRemoteInvitationMessage,
  RTMChannelMessage,
  RTMMemberInfo,
} from './types.d';


export interface RtmEngineEvents {
  /**
   * @event
   * @param evt The received event object
   * error | occurs when wrapper emit error  | on("error") |
   */
  error: (evt: any) => void

  /**
   * @event
   * @param evt The received event object {@link ConnectionState}
   * connectionStateChanged | occurs when connection state changed | 
   */
  connectionStateChanged: (evt: ConnectionState) => void

  /**
   * @event
   * @param evt The received event object {@link RTMPeerMessage}
   * messageReceived | occurs when message received | 
   */
  messageReceived: (evt: any) => void

  /**
   * @event
   * @param evt The received event object {@link RTMLocalInvitationMessage}
   * localInvitationReceivedByPeer | occurs when local inviation received by peer |
   */
  localInvitationReceivedByPeer: (evt: RTMLocalInvitationMessage) => void

  /**
   * @event
   * @param evt The received event object {@link RTMLocalInvitationMessage}
   * localInvitationAccepted | occurs when local invitation accepted | 
   */
  localInvitationAccepted: (evt: RTMLocalInvitationMessage) => void

  /**
   * @event
   * @param evt The received event object {@link RTMLocalInvitationMessage}
   * localInvitationRefused | occurs when local invitation refused |
   */
  localInvitationRefused: (evt: RTMLocalInvitationMessage) => void

  /**
   * @event
   * @param evt The received event object {@link RTMLocalInvitationMessage}
   * localInvitationCanceled | occurs when local invitation canceled |
   */
  localInvitationCanceled: (evt: RTMLocalInvitationMessage) => void

  /**
   * @event 
   * @param evt The received event object {@link RTMLocalInvitationErrorMessage}
   * localInvitationFailure | occurs when local invitation failure |
   */
  localInvitationFailure: (evt: RTMLocalInvitationErrorMessage) => void

  /**
   * @event
   * @param evt The received event object {@link RTMRemoteInvitationErrorMessage}
   * remoteInvitationFailure | occurs when remote invitation failure |
   */
  remoteInvitationFailure: (evt: RTMRemoteInvitationErrorMessage) => void

  /**
   * @event
   * @param evt The received event object {@link RTMRemoteInvitationMessage}
   * remoteInvitationReceived | occurs when remote invitation received |
   */
  remoteInvitationReceived: (evt: RTMRemoteInvitationMessage) => void

  /**
   * @event
   * @param evt The received event object {@link RTMRemoteInvitationMessage}
   * remoteInvitationAccepted | occurs when remote invitation accepted |
   */
  remoteInvitationAccepted: (evt: RTMRemoteInvitationMessage) => void

  /**
    * @event
    * @param evt The received event object {@link RTMRemoteInvitationMessage}
    * remoteInvitationRefused | occurs when remote invitation refused |
    */
  remoteInvitationRefused: (evt: RTMRemoteInvitationMessage) => void

  /**
    * @event
    * @param evt The received event object {@link RTMRemoteInvitationMessage}
    * remoteInvitationCanceled | occurs when remote invitation canceled |
    */
  remoteInvitationCanceled: (evt: RTMRemoteInvitationMessage) => void

  /**
    * @event
    * @param evt The received event object {@link RTMChannelMessage}
    * channelMessageReceived | occurs when received channel message |
   */
  channelMessageReceived: (evt: RTMChannelMessage) => void

  /**
    * @event
    * @param evt The received event object {@link RTMMemberInfo}
    * channelMemberJoined | occurs when some one joined in the subscribed channel
   */
  channelMemberJoined: (evt: RTMMemberInfo) => void

  /**
   * @event
   * @param evt The received event object {@link RTMMemberInfo}
   * channelMemberLeft | occurs when sone one left from u subscribed channel
   */
  channelMemberLeft: (evt: RTMMemberInfo) => void

  /**
   * @event
   * @param evt The received event object
   * tokenExpired | occurs when token has expired |
   */
  tokenExpired: (evt: any) => void
}

export enum LogLevel {
  OFF = 0,
  INFO = 0x0f,
  WARNING = 0x0e,
  ERROR = 0x0c,
  CRITICAL =0x08
};

import {
  NativeModules,
  NativeEventEmitter,
  EmitterSubscription,
} from 'react-native';

const { AgoraRTM } = NativeModules;

/**
 * `RtmEngine` is the entry point of the react native agora rtm sdk. You can call the {@link createClient} method of {@link RtmEngine} to create an `RtmEngine` instance.
 * @noInheritDoc
 */
export default class RtmEngine {

  static init: boolean = false;

  // sdk version
  private static readonly version: string = '1.0.0-alpha.1';

  // internal event identifiy for RtmEngine
  private static readonly AG_RTMCHANNEL = "ag_rtm_";

  // this property is only for dispatch event in RtmEngine instance.
  private readonly events: NativeEventEmitter;

  // this property is only monitor NativeEventEmitter Subscription.
  private readonly internalEventSubscriptions: EmitterSubscription[];

  // create RtmEngine instance
  constructor () {
    this.events = new NativeEventEmitter(AgoraRTM);
    this.internalEventSubscriptions = [];
  }

  /**
   * get the version of rtm sdk
   * @param callback (version) => {} required
   */
  getSdkVersion (callback: Callback): void {
    AgoraRTM.getSdkVersion(callback);
  }

  /**
   * set sdk log file
   * @param path string: specified the generated log path
   * @param level {@link LogLevel}: sdk log level (0: "OFF", 0x0f: "INFO", 0x0e: "WARN", 0x0c: "ERROR", 0x08: "CRITICAL")
   * @param size number: file size in kbytes
   * Note File size settings of less than 512 KB or greater than 10 MB will not take effect.
   * @return Promise<any> This method will return {path: boolean, level: boolean, size: boolean}
   */
  setSdkLog (path: string, level: LogLevel, size: number): Promise<any> {
    return AgoraRTM.setSdkLog(path, level, size)
  }

  /**
   * supports platform: ios, android
   * @events {@link RtmEngineEvents}
   * @param evtName string required
   * @param callback (evt) => {} required
   */
  on<EventName extends keyof RtmEngineEvents>(eventName: EventName, callback: RTMEventCallback) {
    this.internalEventSubscriptions.push(this.events.addListener(`${RtmEngine.AG_RTMCHANNEL}${eventName}`, callback));
  }

  /**
   * supports platform: ios, android
   * This method creates AgoraRTM instance and begin event observing, collect all both remote and local invitations and channels resources.
   * method: createClient
   * @param appId String
   * @return void
   */
  createClient(appId: string): void {
    if (RtmEngine.init === true) return;
    AgoraRTM.init(appId);
    RtmEngine.init = true;
    return;
  }

  // removeEvents
  removeEvents () {
    for (let i = this.internalEventSubscriptions.length; i >= 0; i--) {
      if (this.internalEventSubscriptions[i]) {
        this.internalEventSubscriptions[i].remove();
      }
      this.internalEventSubscriptions.splice(i, 1);
    }
  }

  /**
   * supports platform: ios, android
   * This method destroy AgoraRTM instance, stop event observing, release all both remote and local invitaitons and channels resources.
   * @param void
   * @return void
   */
  destroyClient(): void {
    if (RtmEngine.init === false) return;
    this.removeEvents();
    AgoraRTM.destroy();
    RtmEngine.init = false;
    return;
  }

  /**
   * supports platform: ios, android
   * This method do login with UserInfo
   * @param params {@link UserInfo}
   * ---
   * token | string | optional |
   * uid | string | required |
   * ---
   * @return Promise<any>
   */
  login(params: UserInfo): Promise<any> {
    return AgoraRTM.login(params);
  }

  /**
   * supports platform: ios, android
   * This method do logout.
   * @return Promise<any>
   */
  logout(): Promise<any> {
    return AgoraRTM.logout();
  }

  /**
   * supports platform: ios, android
   * This method do renewToken when got `tokenExpired` event.
   * @param token String
   * @return Promise<any>
   */
  renewToken(token: String): Promise<any> {
    return AgoraRTM.renewToken(token);
  }

  /**
   * supports platform: ios, android
   * This method do send p2p message with {@link AgoraPeerMessage}
   * @param params AgoraPeerMessage
   * ---
   * peerId | string | required |
   * offline | boolean | requried |
   * text | string | required |
   * ---
   * @return Promise<any>
   */
  sendMessageToPeer(params: AgoraPeerMessage): Promise<any> {
    return AgoraRTM.sendMessageToPeer(params);
  }

  /**
   * supports platform: ios, android
   * This method do join channel with channelId
   * @param channelId string
   * @return Promise<any>
   */
  joinChannel(channelId: string): Promise<any> {
    return AgoraRTM.joinChannel(channelId);
  }

  /**
   * supports platform: ios, android
   * This method do leave channel with channelId
   * @param channelId string
   * @return Promise<any>
   */
  leaveChannel(channelId: string): Promise<any> {
    return AgoraRTM.leaveChannel(channelId);
  }

  /**
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
  getChannelMembersBychannelId(channelId: string): Promise<any> {
    return AgoraRTM.getChannelMembersBychannelId(channelId);
  }

  /**
   * supports platform: ios, android
   * This method enables send message by channel id.
   * NOTICE: text bytelength has MAX_SIZE 32kb limit.
   * @param channelId string.
   * @param text string (bytesize shouldn't >= 32kb)
   * @return Promise<any>
   */
  sendMessageByChannelId(channelId: string, text: string): Promise<any> {
    return AgoraRTM.sendMessageByChannelId({channelId, text});
  }

  /**
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
  queryPeersOnlineStatus(ids: string []): Promise<any> {
    return AgoraRTM.queryPeersOnlineStatus({ids});
  }

  /**
   * supports platform: ios, android
   * This method enables set local user attributes with attributes {@link UserAttribute}
   * @param attributes {@link UserAttribute []}
   * @return Promise<any>
   * 
   * UserAttribute
   * --- 
   * key | string | required |
   * value | string | required |
   * ---
   */
  setLocalUserAttributes(attributes: UserAttribute[]): Promise<any> {
    return AgoraRTM.setLocalUserAttributes({attributes});
  }

  /**
   * supports platform: ios, android
   * This method enables you to replace attribute already exists or add attribute wasn't set for local user attributes;
   * @param attributes {@link UserAttribute []}
   * @return Promise<any>
   */
  replaceLocalUserAttributes(attributes: UserAttribute[]): Promise<any> {
    return AgoraRTM.replaceLocalUserAttributes({attributes});
  }

  /**
   * supports platform: ios, android
   * This method enables you to remove exists attribute for local user.
   * @param keys string []
   * @return Promise<any>
   */
  removeLocalUserAttributesByKeys(keys: string[]): Promise<any> {
    return AgoraRTM.removeLocalUserAttributesByKeys({keys});
  }

  /**
   * supports platform: ios, android
   * This method enables you to remove all of local user attributes;
   * @param void
   * @return Promise<any>
   */
  removeAllLocalUserAttributes(): Promise<any> {
    return AgoraRTM.removeAllLocalUserAttributes();
  }

  /**
   * supports platform: ios, android
   * This method enables you get user attributes by uid.
   * @param uid string. user id
   * @return Promise<UserProfile> {@link UserProfile}
   */
  getUserAttributesByUid(uid: string): Promise<UserProfile> {
    return AgoraRTM.getUserAttributesByUid(uid);
  }

  /**
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
   * @return Promise<any>
   */
  sendLocalInvitation(invitationProps: LocalInvitationProps): Promise<any> {
    return AgoraRTM.sendLocalInvitation(invitationProps);
  }

  /**
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
  cancelLocalInvitation(invitationProps: LocalInvitationProps): Promise<any> {
    return AgoraRTM.cancelLocalInvitation(invitationProps);
  }

  /**
   * supports platform: ios, android
   * This method enables accept remote invitation with RemoteInvitationProps.
   * NOTICE: content bytelength has MAX_SIZE 32kb limit.
   * @param invitationProps {@link RemoteInvitationProps}
   * 
   * RemoteInvitationProps
   * ---
   * uid | string | required |
   * channelId | string | required |
   * response | string | optional | 32kb limit |
   * ---
   * 
   * @return Promise<any>
   */
  acceptRemoteInvitation(remoteInvitationProps: RemoteInvitationProps): Promise<any> {
    return AgoraRTM.sendRemoteInvitation(remoteInvitationProps);
  }

  /**
   * supports platform: ios, android
   * This method enables refuse remote invitation with RemoteInvitationProps.
   * NOTICE: content bytelength has MAX_SIZE 32kb limit.
   * @param invitationProps {@link RemoteInvitationProps}
   * 
   * RemoteInvitationProps
   * ---
   * uid | string | required |
   * channelId | string | required |
   * response | string | optional | 32kb limit |
   * ---
   * 
   * @return Promise<any>
   */
  refuseRemoteInvitation(remoteInvitationProps: RemoteInvitationProps): Promise<any> {
    return AgoraRTM.refuseRemoteInvitation(remoteInvitationProps);
  }

};