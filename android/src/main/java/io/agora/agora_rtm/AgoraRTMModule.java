package io.agora.agora_rtm;

import android.text.TextUtils;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.Nonnull;
import javax.annotation.Nullable;

import io.agora.rtm.ErrorInfo;
import io.agora.rtm.LocalInvitation;
import io.agora.rtm.RemoteInvitation;
import io.agora.rtm.ResultCallback;
import io.agora.rtm.RtmAttribute;
import io.agora.rtm.RtmCallEventListener;
import io.agora.rtm.RtmChannel;
import io.agora.rtm.RtmChannelAttribute;
import io.agora.rtm.RtmChannelListener;
import io.agora.rtm.RtmChannelMember;
import io.agora.rtm.RtmClient;
import io.agora.rtm.RtmClientListener;
import io.agora.rtm.RtmMessage;

public class AgoraRTMModule extends ReactContextBaseJavaModule
  implements RtmClientListener, RtmCallEventListener, RtmChannelListener {
  private RtmClient rtmClient;
  private final Map<String, RtmChannel> channels;
  private final Map<Integer, LocalInvitation> localInvitations;
  private final Map<Integer, RemoteInvitation> remoteInvitations;

  private boolean hasListeners = false;

  private static class BaseResultCallback<T> implements ResultCallback<T> {
    private final Promise promise;

    public BaseResultCallback(Promise promise) {
      this.promise = promise;
    }

    @Override
    public void onSuccess(T t) {
      promise.resolve(null);
    }

    @Override
    public void onFailure(ErrorInfo errorInfo) {
      promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
    }
  }

  public AgoraRTMModule(ReactApplicationContext ctx) {
    super(ctx);
    channels = new HashMap<>();
    localInvitations = new HashMap<>();
    remoteInvitations = new HashMap<>();
  }

  @Nonnull
  @Override
  public String getName() {
    return "AgoraRTM";
  }

  @Nullable
  @Override
  public Map<String, Object> getConstants() {
    return MapBuilder.of("prefix", "io.agora.rtm.");
  }

  private void startObserving() {
    hasListeners = true;
  }

  private void stopObserving() {
    hasListeners = false;
  }

  private void sendEvent(String eventName, @Nullable WritableArray params) {
    if (hasListeners) {
      getReactApplicationContext()
        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
        .emit("io.agora.rtm." + eventName, params);
    }
  }

  @ReactMethod
  public void destroy(Promise promise) {
    stopObserving();
    localInvitations.clear();
    remoteInvitations.clear();
    for (Map.Entry<String, RtmChannel> entry : channels.entrySet()) {
      entry.getValue().release();
    }
    channels.clear();
    rtmClient.release();
    rtmClient = null;
    promise.resolve(null);
  }

  @ReactMethod
  public void login(ReadableMap params, Promise promise) {
    HashMap<String, Object> map = params.toHashMap();
    rtmClient.login(Extensions.getString(map, "token"), Extensions.getString(map, "userId"), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void logout(Promise promise) {
    rtmClient.logout(new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void sendMessageToPeer(ReadableMap params, Promise promise) {
    HashMap<String, Object> map = params.toHashMap();
    rtmClient.sendMessageToPeer(Extensions.getString(map, "peerId"), Extensions.mapToRtmMessage(map, rtmClient), Extensions.mapToSendMessageOptions(map), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void queryPeersOnlineStatus(ReadableMap params, Promise promise) {
    rtmClient.queryPeersOnlineStatus(Extensions.mapToPeerIds(params.toHashMap()), new BaseResultCallback<Map<String, Boolean>>(promise) {
      @Override
      public void onSuccess(Map<String, Boolean> result) {
        promise.resolve(Arguments.makeNativeMap(new HashMap<String, Object>() {{
          putAll(result);
        }}));
      }
    });
  }

  @ReactMethod
  public void subscribePeersOnlineStatus(ReadableMap params, Promise promise) {
    rtmClient.subscribePeersOnlineStatus(Extensions.mapToPeerIds(params.toHashMap()), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void unsubscribePeersOnlineStatus(ReadableMap params, Promise promise) {
    rtmClient.unsubscribePeersOnlineStatus(Extensions.mapToPeerIds(params.toHashMap()), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void queryPeersBySubscriptionOption(ReadableMap params, Promise promise) {
    rtmClient.queryPeersBySubscriptionOption(Extensions.getInt(params.toHashMap(), "option"), new BaseResultCallback<Set<String>>(promise) {
      @Override
      public void onSuccess(Set<String> result) {
        promise.resolve(Arguments.makeNativeArray(result.toArray()));
      }
    });
  }

  @ReactMethod
  public void renewToken(ReadableMap params, Promise promise) {
    rtmClient.renewToken(Extensions.getString(params.toHashMap(), "token"), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void setLocalUserAttributes(ReadableMap params, Promise promise) {
    rtmClient.setLocalUserAttributes(Extensions.mapToUserAttributes(params.toHashMap()), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void addOrUpdateLocalUserAttributes(ReadableMap params, Promise promise) {
    rtmClient.addOrUpdateLocalUserAttributes(Extensions.mapToUserAttributes(params.toHashMap()), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void deleteLocalUserAttributesByKeys(ReadableMap params, Promise promise) {
    rtmClient.deleteLocalUserAttributesByKeys(Extensions.mapToAttributeKeys(params.toHashMap()), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void clearLocalUserAttributes(Promise promise) {
    rtmClient.clearLocalUserAttributes(new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void getUserAttributes(ReadableMap params, Promise promise) {
    rtmClient.getUserAttributes(Extensions.getString(params.toHashMap(), "userId"), new BaseResultCallback<List<RtmAttribute>>(promise) {
      @Override
      public void onSuccess(List<RtmAttribute> rtmAttributes) {
        promise.resolve(Arguments.makeNativeArray(new ArrayList<Object>() {{
          for (RtmAttribute attribute : rtmAttributes) {
            add(Extensions.toMap(attribute));
          }
        }}));
      }
    });
  }

  @ReactMethod
  public void getUserAttributesByKeys(ReadableMap params, Promise promise) {
    HashMap<String, Object> map = params.toHashMap();
    rtmClient.getUserAttributesByKeys(Extensions.getString(map, "userId"), Extensions.mapToAttributeKeys(map), new BaseResultCallback<List<RtmAttribute>>(promise) {
      @Override
      public void onSuccess(List<RtmAttribute> rtmAttributes) {
        promise.resolve(Arguments.makeNativeArray(new ArrayList<Object>() {{
          for (RtmAttribute attribute : rtmAttributes) {
            add(Extensions.toMap(attribute));
          }
        }}));
      }
    });
  }

  @ReactMethod
  public void setChannelAttributes(ReadableMap params, Promise promise) {
    HashMap<String, Object> map = params.toHashMap();
    rtmClient.setChannelAttributes(Extensions.getString(map, "channelId"), Extensions.mapToChannelAttributes(map), Extensions.mapToChannelAttributeOptions(map), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void addOrUpdateChannelAttributes(ReadableMap params, Promise promise) {
    HashMap<String, Object> map = params.toHashMap();
    rtmClient.addOrUpdateChannelAttributes(Extensions.getString(map, "channelId"), Extensions.mapToChannelAttributes(map), Extensions.mapToChannelAttributeOptions(map), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void deleteChannelAttributesByKeys(ReadableMap params, Promise promise) {
    HashMap<String, Object> map = params.toHashMap();
    rtmClient.deleteChannelAttributesByKeys(Extensions.getString(map, "channelId"), Extensions.mapToAttributeKeys(map), Extensions.mapToChannelAttributeOptions(map), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void clearChannelAttributes(ReadableMap params, Promise promise) {
    HashMap<String, Object> map = params.toHashMap();
    rtmClient.clearChannelAttributes(Extensions.getString(map, "channelId"), Extensions.mapToChannelAttributeOptions(map), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void getChannelAttributes(ReadableMap params, Promise promise) {
    rtmClient.getChannelAttributes(Extensions.getString(params.toHashMap(), "channelId"), new BaseResultCallback<List<RtmChannelAttribute>>(promise) {
      @Override
      public void onSuccess(List<RtmChannelAttribute> rtmAttributes) {
        promise.resolve(Arguments.makeNativeArray(new ArrayList<Object>() {{
          for (RtmChannelAttribute attribute : rtmAttributes) {
            add(Extensions.toMap(attribute));
          }
        }}));
      }
    });
  }

  @ReactMethod
  public void getChannelAttributesByKeys(ReadableMap params, Promise promise) {
    HashMap<String, Object> map = params.toHashMap();
    rtmClient.getChannelAttributesByKeys(Extensions.getString(map, "channelId"), Extensions.mapToAttributeKeys(map), new BaseResultCallback<List<RtmChannelAttribute>>(promise) {
      @Override
      public void onSuccess(List<RtmChannelAttribute> rtmAttributes) {
        promise.resolve(Arguments.makeNativeArray(new ArrayList<Object>() {{
          for (RtmChannelAttribute attribute : rtmAttributes) {
            add(Extensions.toMap(attribute));
          }
        }}));
      }
    });
  }

  @ReactMethod
  public void setParameters(ReadableMap params, Promise promise) {
    int res = rtmClient.setParameters(Extensions.getString(params.toHashMap(), "parameters"));
    if (res == 0) {
      promise.resolve(null);
    } else {
      promise.reject(String.valueOf(res), "");
    }
  }

  @ReactMethod
  public void setLogFile(ReadableMap params, Promise promise) {
    int res = rtmClient.setLogFile(Extensions.getString(params.toHashMap(), "filePath"));
    if (res == 0) {
      promise.resolve(null);
    } else {
      promise.reject(String.valueOf(res), "");
    }
  }

  @ReactMethod
  public void setLogFilter(ReadableMap params, Promise promise) {
    int res = rtmClient.setLogFilter(Extensions.getInt(params.toHashMap(), "filter"));
    if (res == 0) {
      promise.resolve(null);
    } else {
      promise.reject(String.valueOf(res), "");
    }
  }

  @ReactMethod
  public void setLogFileSize(ReadableMap params, Promise promise) {
    int res = rtmClient.setLogFileSize(Extensions.getInt(params.toHashMap(), "fileSizeInKBytes"));
    if (res == 0) {
      promise.resolve(null);
    } else {
      promise.reject(String.valueOf(res), "");
    }
  }

  @ReactMethod
  public void createInstance(String appId, Promise promise) {
    try {
      rtmClient = RtmClient.createInstance(getReactApplicationContext(), appId, this);
      rtmClient.getRtmCallManager().setEventListener(this);
      startObserving();
      promise.resolve(null);
    } catch (Exception exception) {
      promise.reject(exception);
    }
  }

  @ReactMethod
  public void getSdkVersion(Promise promise) {
    promise.resolve(RtmClient.getSdkVersion());
  }

  @ReactMethod
  public void joinChannel(ReadableMap params, Promise promise) {
    RtmChannel rtmChannel = getRtmChannel(params, promise, true);
    if (rtmChannel == null) return;
    channels.put(rtmChannel.getId(), rtmChannel);
    rtmChannel.join(new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void leaveChannel(ReadableMap params, Promise promise) {
    RtmChannel rtmChannel = getRtmChannel(params, promise, false);
    if (rtmChannel == null) return;
    rtmChannel.leave(new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void sendMessage(ReadableMap params, Promise promise) {
    RtmChannel rtmChannel = getRtmChannel(params, promise, false);
    if (rtmChannel == null) return;
    HashMap<String, Object> map = params.toHashMap();
    rtmChannel.sendMessage(Extensions.mapToRtmMessage(map, rtmClient), Extensions.mapToSendMessageOptions(map), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void getMembers(ReadableMap params, Promise promise) {
    RtmChannel rtmChannel = getRtmChannel(params, promise, false);
    if (rtmChannel == null) return;
    rtmChannel.getMembers(new BaseResultCallback<List<RtmChannelMember>>(promise) {
      @Override
      public void onSuccess(List<RtmChannelMember> rtmChannelMembers) {
        promise.resolve(Arguments.makeNativeArray(new ArrayList<Object>() {{
          for (RtmChannelMember member : rtmChannelMembers) {
            add(Extensions.toMap(member));
          }
        }}));
      }
    });
  }

  @ReactMethod
  public void releaseChannel(ReadableMap params, Promise promise) {
    RtmChannel rtmChannel = getRtmChannel(params, promise, false);
    if (rtmChannel == null) return;
    channels.remove(rtmChannel.getId());
    rtmChannel.release();
    promise.resolve(null);
  }

  @Nullable
  private RtmChannel getRtmChannel(ReadableMap params, Promise promise, boolean init) {
    String channelId = Extensions.getString(params.toHashMap(), "channelId");
    RtmChannel rtmChannel = channels.get(channelId);
    if (rtmChannel == null) {
      if (init) {
        return rtmClient.createChannel(channelId, this);
      }
      promise.reject("101", "");
    }
    return rtmChannel;
  }

  @Nullable
  private LocalInvitation getLocalInvitation(ReadableMap params) {
    LocalInvitation ret = null;
    Map<?, ?> localInvitation = Extensions.getMap(params.toHashMap(), "localInvitation");
    int hash = Extensions.getInt(localInvitation, "hash");
    if (hash == 0) {
      for (Map.Entry<Integer, LocalInvitation> entry : localInvitations.entrySet()) {
        if (entry.getValue().getCalleeId().equals(Extensions.getString(localInvitation, "calleeId"))) {
          ret = entry.getValue();
          break;
        }
      }
    } else {
      ret = localInvitations.get(hash);
    }
    String content = Extensions.getString(localInvitation, "content");
    if (!TextUtils.isEmpty(content))
      ret.setContent(content);
    String channelId = Extensions.getString(localInvitation, "channelId");
    if (!TextUtils.isEmpty(channelId))
      ret.setChannelId(channelId);
    return ret;
  }

  @Nullable
  private RemoteInvitation getRemoteInvitation(ReadableMap params) {
    RemoteInvitation ret = null;
    Map<?, ?> remoteInvitation = Extensions.getMap(params.toHashMap(), "remoteInvitation");
    int hash = Extensions.getInt(remoteInvitation, "hash");
    if (hash == 0) {
      for (Map.Entry<Integer, RemoteInvitation> entry : remoteInvitations.entrySet()) {
        if (entry.getValue().getCallerId().equals(Extensions.getString(remoteInvitation, "callerId"))) {
          ret = entry.getValue();
          break;
        }
      }
    } else {
      ret = remoteInvitations.get(hash);
    }
    String response = Extensions.getString(remoteInvitation, "response");
    if (!TextUtils.isEmpty(response))
      ret.setResponse(response);
    return ret;
  }

  @ReactMethod
  public void createLocalInvitation(ReadableMap params, Promise promise) {
    LocalInvitation localInvitation = Extensions.mapToLocalInvitation(params.toHashMap(), rtmClient.getRtmCallManager());
    localInvitations.put(System.identityHashCode(localInvitation), localInvitation);
    promise.resolve(Arguments.makeNativeMap(Extensions.toMap(localInvitation)));
  }

  @ReactMethod
  public void sendLocalInvitation(ReadableMap params, Promise promise) {
    rtmClient.getRtmCallManager().sendLocalInvitation(getLocalInvitation(params), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void cancelLocalInvitation(ReadableMap params, Promise promise) {
    rtmClient.getRtmCallManager().cancelLocalInvitation(getLocalInvitation(params), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void acceptRemoteInvitation(ReadableMap params, Promise promise) {
    rtmClient.getRtmCallManager().acceptRemoteInvitation(getRemoteInvitation(params), new BaseResultCallback<>(promise));
  }

  @ReactMethod
  public void refuseRemoteInvitation(ReadableMap params, Promise promise) {
    rtmClient.getRtmCallManager().refuseRemoteInvitation(getRemoteInvitation(params), new BaseResultCallback<>(promise));
  }

  /* RtmClientListener */

  @Override
  public void onConnectionStateChanged(int state, int reason) {
    WritableArray ret = Arguments.createArray();
    ret.pushInt(state);
    ret.pushInt(reason);
    sendEvent(AgoraRTMConstants.ConnectionStateChanged, ret);
  }

  @Override
  public void onMessageReceived(RtmMessage rtmMessage, String peerId) {
    WritableArray ret = Arguments.createArray();
    ret.pushMap(Arguments.makeNativeMap(Extensions.toMap(rtmMessage)));
    ret.pushString(peerId);
    sendEvent(AgoraRTMConstants.MessageReceived, ret);
  }

  @Override
  public void onTokenExpired() {
    sendEvent(AgoraRTMConstants.TokenExpired, null);
  }

  @Override
  public void onPeersOnlineStatusChanged(Map<String, Integer> map) {
    WritableArray ret = Arguments.createArray();
    ret.pushMap(Arguments.makeNativeMap(new HashMap<String, Object>() {{
      putAll(map);
    }}));
    sendEvent(AgoraRTMConstants.PeersOnlineStatusChanged, ret);
  }

  /* RtmChannelListener */

  @Override
  public void onMemberJoined(RtmChannelMember rtmChannelMember) {
    WritableArray ret = Arguments.createArray();
    ret.pushMap(Arguments.makeNativeMap(Extensions.toMap(rtmChannelMember)));
    sendEvent(AgoraRTMConstants.ChannelMemberJoined, ret);
  }

  @Override
  public void onMemberLeft(RtmChannelMember rtmChannelMember) {
    WritableArray ret = Arguments.createArray();
    ret.pushMap(Arguments.makeNativeMap(Extensions.toMap(rtmChannelMember)));
    sendEvent(AgoraRTMConstants.ChannelMemberLeft, ret);
  }

  @Override
  public void onMessageReceived(RtmMessage rtmMessage, RtmChannelMember rtmChannelMember) {
    WritableArray ret = Arguments.createArray();
    ret.pushMap(Arguments.makeNativeMap(Extensions.toMap(rtmMessage)));
    ret.pushMap(Arguments.makeNativeMap(Extensions.toMap(rtmChannelMember)));
    sendEvent(AgoraRTMConstants.ChannelMessageReceived, ret);
  }

  @Override
  public void onAttributesUpdated(List<RtmChannelAttribute> list) {
    WritableArray ret = Arguments.createArray();
    ret.pushArray(Arguments.makeNativeArray(new ArrayList<Object>() {{
      for (RtmChannelAttribute attribute : list) {
        add(Extensions.toMap(attribute));
      }
    }}));
    sendEvent(AgoraRTMConstants.ChannelAttributesUpdated, ret);
  }

  @Override
  public void onMemberCountUpdated(int i) {
    WritableArray ret = Arguments.createArray();
    ret.pushInt(i);
    sendEvent(AgoraRTMConstants.MemberCountUpdated, ret);
  }

  /* RtmCallEventListener */

  @Override
  public void onLocalInvitationReceivedByPeer(LocalInvitation localInvitation) {
    WritableArray ret = Arguments.createArray();
    ret.pushMap(Arguments.makeNativeMap(Extensions.toMap(localInvitation)));
    sendEvent(AgoraRTMConstants.LocalInvitationReceivedByPeer, ret);
  }

  @Override
  public void onLocalInvitationAccepted(LocalInvitation localInvitation, String response) {
    localInvitations.remove(System.identityHashCode(localInvitation));
    WritableArray ret = Arguments.createArray();
    ret.pushMap(Arguments.makeNativeMap(Extensions.toMap(localInvitation)));
    ret.pushString(response);
    sendEvent(AgoraRTMConstants.LocalInvitationAccepted, ret);
  }

  @Override
  public void onLocalInvitationRefused(LocalInvitation localInvitation, String response) {
    localInvitations.remove(System.identityHashCode(localInvitation));
    WritableArray ret = Arguments.createArray();
    ret.pushMap(Arguments.makeNativeMap(Extensions.toMap(localInvitation)));
    ret.pushString(response);
    sendEvent(AgoraRTMConstants.LocalInvitationRefused, ret);
  }

  @Override
  public void onLocalInvitationCanceled(LocalInvitation localInvitation) {
    localInvitations.remove(System.identityHashCode(localInvitation));
    WritableArray ret = Arguments.createArray();
    ret.pushMap(Arguments.makeNativeMap(Extensions.toMap(localInvitation)));
    sendEvent(AgoraRTMConstants.LocalInvitationCanceled, ret);
  }

  @Override
  public void onLocalInvitationFailure(LocalInvitation localInvitation, int code) {
    localInvitations.remove(System.identityHashCode(localInvitation));
    WritableArray ret = Arguments.createArray();
    ret.pushMap(Arguments.makeNativeMap(Extensions.toMap(localInvitation)));
    ret.pushInt(code);
    sendEvent(AgoraRTMConstants.LocalInvitationFailure, ret);
  }

  @Override
  public void onRemoteInvitationReceived(RemoteInvitation remoteInvitation) {
    remoteInvitations.put(System.identityHashCode(remoteInvitation), remoteInvitation);
    WritableArray ret = Arguments.createArray();
    ret.pushMap(Arguments.makeNativeMap(Extensions.toMap(remoteInvitation)));
    sendEvent(AgoraRTMConstants.RemoteInvitationReceived, ret);
  }

  @Override
  public void onRemoteInvitationRefused(RemoteInvitation remoteInvitation) {
    remoteInvitations.remove(System.identityHashCode(remoteInvitation));
    WritableArray ret = Arguments.createArray();
    ret.pushMap(Arguments.makeNativeMap(Extensions.toMap(remoteInvitation)));
    sendEvent(AgoraRTMConstants.RemoteInvitationRefused, ret);
  }

  @Override
  public void onRemoteInvitationAccepted(RemoteInvitation remoteInvitation) {
    remoteInvitations.remove(System.identityHashCode(remoteInvitation));
    WritableArray ret = Arguments.createArray();
    ret.pushMap(Arguments.makeNativeMap(Extensions.toMap(remoteInvitation)));
    sendEvent(AgoraRTMConstants.RemoteInvitationAccepted, ret);
  }

  @Override
  public void onRemoteInvitationCanceled(RemoteInvitation remoteInvitation) {
    remoteInvitations.remove(System.identityHashCode(remoteInvitation));
    WritableArray ret = Arguments.createArray();
    ret.pushMap(Arguments.makeNativeMap(Extensions.toMap(remoteInvitation)));
    sendEvent(AgoraRTMConstants.RemoteInvitationCanceled, ret);
  }

  @Override
  public void onRemoteInvitationFailure(RemoteInvitation remoteInvitation, int code) {
    remoteInvitations.remove(System.identityHashCode(remoteInvitation));
    WritableArray ret = Arguments.createArray();
    ret.pushMap(Arguments.makeNativeMap(Extensions.toMap(remoteInvitation)));
    ret.pushInt(code);
    sendEvent(AgoraRTMConstants.RemoteInvitationFailure, ret);
  }
}
