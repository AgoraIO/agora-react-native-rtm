import { Logger } from './utils'
import RtmEngine from 'agora-react-native-rtm'
import { EventEmitter } from 'events'
import { APP_ID } from './utils'

export default class RtmAdapter extends EventEmitter {
  private readonly client: RtmEngine
  public uid: string | any

  constructor() {
    super()
    this.uid = null
    this.client = new RtmEngine()
    const events = [
      "error",
      "messageReceived",
      "channelMessageReceived",
      "channelMemberJoined",
      "channelMemberLeft",
      "tokenExpired",
      "connectionStateChanged",
    ]

    events.forEach((event: string) => {
      this.client.on(event, (evt: any) => {
        this.emit(event, evt)
      })
    })
  }

  async login(uid: string): Promise<any> {
    this.client.createClient(APP_ID)
    this.uid = uid
    return this.client.login({
      uid: this.uid
    })
  }

  async logout(): Promise<any> {
    await this.client.logout()
    Logger.log("logout success")
    this.destroy()
    Logger.log("destroy")
    return;
  }

  async join(cid: string): Promise<any> {
    return this.client.joinChannel(cid)
  }

  async leave(cid: string): Promise<any> {
    return this.client.leaveChannel(cid)
  }

  async sendChannelMessage(param: { channel: string, message: string }): Promise<any> {
    return this.client.sendMessageByChannelId(param.channel, param.message)
  }

  destroy() {
    this.client.destroyClient()
  }
}
