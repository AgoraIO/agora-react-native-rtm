import { Text } from "react-native";

export interface AgoraRTMClientOptions {
  appID: string
  token?: string
  logined?: boolean
  connectionState: string
}

export interface AgoraMessage {
  text: string
  channelId?: string
  peerId?: string
}

export type RTMEventCallback = () => {}

export interface UserInfo {
  token?: string
  uid: String
}

export interface AgoraPeerMessage {
  peerId: string
  offline: boolean
  text: string
}

export interface UserAttribute {
  key: string
  value: string
}

export interface LocalInvitationProps {
  uid: string
  content?: string
  channelId: string
}

export interface RemoteInvitationProps {
  uid: string
  response?: string
  channelId: string
}

export interface MemberInfo {
  uid: string
  channelId: string
}

export interface Members {
  members: MemberInfo[]
}

export interface MemberStatus {
  uid: string
  online: boolean
}

export interface ListPeerStatus {
  items: MemberStatus[]
}

export interface UserProfile {
  uid: string
  attributes: any
}

export interface ConnectionState {
  state: number
  reason: number
}

export interface RTMPeerMessage {
  text: string // received text
  ts: string // received time
  offline: boolean // offline state
  peerId: string // peer id
}

export interface RTMChannelMessage {
  channelId: string // channel id
  uid: string // sender uid
  text: string // text
  ts: string // time string
  offline: boolean // offline state
}

export interface RTMLocalInvitationMessage {
  calleeId: string // callee id
  content: string // content
  state: number // state 
  channelId: string // channel id
  response: string // response
}

export interface RTMLocalInvitationErrorMessage {
  calleeId: string // callee id
  content: string // content
  state: number // state
  channelId: string // channel id
  response: string // response
  code: number // error code
}

export interface RTMRemoteInvitationMessage {
  callerId: string // caller id
  content: string // content
  state: number // state
  channelId: string // channel id
  response: string // response
}

export interface RTMRemoteInvitationErrorMessage {
  callerId: string // caller id
  content: string // content
  state: number // state
  channelId: string // channel id
  response: string // response
  code: number // error code
}

export interface RTMMemberInfo {
  channelId: string
  uid: string
}

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