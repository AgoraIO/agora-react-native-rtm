/**
 * @deprecated
 */
export type Callback = () => {};

/**
 * @deprecated
 */
export interface UserInfo {
  token?: string;
  uid: string;
}

/**
 * @deprecated
 */
export interface AgoraPeerMessage {
  peerId: string;
  offline: boolean;
  text: string;
}

/**
 * @deprecated
 */
export interface UserAttribute {
  key: string;
  value: string;
}

/**
 * @deprecated
 */
export interface LocalInvitationProps {
  uid: string;
  content?: string; // recommnd used with rtm communication
  channelId?: string; // recommnd used with signal service communication
}

/**
 * @deprecated
 */
export interface RemoteInvitationProps {
  uid: string;
  response?: string;
  channelId: string;
}

/**
 * @deprecated
 */
export interface MemberInfo {
  uid: string;
  channelId: string;
}

/**
 * @deprecated
 */
export interface Members {
  members: MemberInfo[];
}

/**
 * @deprecated
 */
export interface MemberStatus {
  uid: string;
  online: boolean;
}

/**
 * @deprecated
 */
export interface ListPeerStatus {
  items: MemberStatus[];
}

/**
 * @deprecated
 */
export interface UserProfile {
  uid: string;
  attributes: any;
}

/**
 * @deprecated
 */
export interface ConnectionState {
  state: number;
  reason: number;
}

/**
 * @deprecated
 */
export interface RTMPeerMessage {
  text: string; // received text
  ts?: string; // received time
  offline?: boolean; // offline state
  peerId: string; // peer id
}

/**
 * @deprecated
 */
export interface RTMChannelMessage {
  channelId: string; // channel id
  uid: string; // sender uid
  text: string; // text
  ts?: string; // time string
  offline?: boolean; // offline state
}

/**
 * @deprecated
 */
export interface RTMLocalInvitationMessage {
  calleeId: string; // callee id
  content?: string; // content
  state?: number; // state
  channelId?: string; // channel id
  response?: string; // response
}

/**
 * @deprecated
 */
export interface RTMLocalInvitationErrorMessage {
  calleeId: string; // callee id
  content?: string; // content
  state?: number; // state
  channelId?: string; // channel id
  response?: string; // response
  code: number; // error code
}

/**
 * @deprecated
 */
export interface RTMRemoteInvitationMessage {
  callerId: string; // caller id
  content?: string; // content
  state?: number; // state
  channelId?: string; // channel id
  response?: string; // response
}

/**
 * @deprecated
 */
export interface RTMRemoteInvitationErrorMessage {
  callerId: string; // caller id
  content?: string; // content
  state?: number; // state
  channelId?: string; // channel id
  response?: string; // response
  code: number; // error code
}

/**
 * @deprecated
 */
export interface RTMMemberInfo {
  channelId: string;
  uid: string;
}

export enum LogLevel {
  OFF = 0,
  INFO = 0x0f,
  WARNING = 0x0e,
  ERROR = 0x0c,
  CRITICAL = 0x08,
}

/**
 * @internal
 * @ignore
 */
export type Listener = (...args: any[]) => any;

/**
 * @internal
 * @ignore
 */
export interface Subscription {
  remove(): void;
}

export class RtmMessage {
  text: string;
  readonly messageType?: number;
  readonly serverReceivedTs?: number;
  readonly isOfflineMessage?: boolean;

  constructor(text: string) {
    this.text = text;
  }
}

export interface SendMessageOptions {
  enableOfflineMessaging?: boolean;
  enableHistoricalMessaging?: boolean;
}

export enum PeerSubscriptionOption {
  ONLINE = 0,
}

export enum PeerOnlineState {
  ONLINE = 0,
  UNREACHABLE = 1,
  OFFLINE = 2,
}

export class RtmAttribute {
  key: string;
  value: string;

  constructor(key: string, value: string) {
    this.key = key;
    this.value = value;
  }
}

export class RtmChannelAttribute extends RtmAttribute {
  readonly lastUpdateUserId?: string;
  readonly lastUpdateTs?: number;
}

export interface RtmChannelMember {
  readonly userId: string;
  readonly channelId: string;
}

export interface ChannelAttributeOptions {
  enableNotificationToChannelMembers: boolean;
}

export interface PeersOnlineStatus {
  [key: string]: PeerOnlineState;
}

export interface LocalInvitation {
  readonly calleeId: string;
  content?: string;
  channelId?: string;
  readonly response?: string;
  readonly state?: LocalInvitationState;
  readonly hash: number;
}

export interface RemoteInvitation {
  readonly callerId: string;
  readonly content?: string;
  readonly channelId?: string;
  response?: string;
  readonly state?: RemoteInvitationState;
  readonly hash: number;
}

export enum RtmConnectionState {
  DISCONNECTED = 1,
  CONNECTING = 2,
  CONNECTED = 3,
  RECONNECTING = 4,
  ABORTED = 5,
}

export enum ConnectionChangeReason {
  LOGIN = 1,
  LOGIN_SUCCESS = 2,
  LOGIN_FAILURE = 3,
  LOGIN_TIMEOUT = 4,
  INTERRUPTED = 5,
  LOGOUT = 6,
  BANNED_BY_SERVER = 7,
  REMOTE_LOGIN = 8,
}

export enum LocalInvitationState {
  IDLE = 0,
  SENT_TO_REMOTE = 1,
  RECEIVED_BY_REMOTE = 2,
  ACCEPTED_BY_REMOTE = 3,
  REFUSED_BY_REMOTE = 4,
  CANCELED = 5,
  FAILURE = 6,
}

export enum LocalInvitationError {
  OK = 0,
  PEER_OFFLINE = 1,
  PEER_NO_RESPONSE = 2,
  INVITATION_EXPIRE = 3,
  NOT_LOGGEDIN = 4,
}

export enum RemoteInvitationState {
  IDLE = 0,
  INVITATION_RECEIVED = 1,
  ACCEPT_SENT_TO_LOCAL = 2,
  REFUSED = 3,
  ACCEPTED = 4,
  CANCELED = 5,
  FAILURE = 6,
}

export enum RemoteInvitationError {
  OK = 0,
  PEER_OFFLINE = 1,
  ACCEPT_FAILURE = 2,
  INVITATION_EXPIRE = 3,
}
