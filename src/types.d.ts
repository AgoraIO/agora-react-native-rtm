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

export type Callback = () => {}

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
  content?: string // recommnd used with rtm communication
  channelId?: string // recommnd used with signal service communication
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