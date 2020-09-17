package io.agora.agora_rtm;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
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
import io.agora.rtm.RtmCallManager;
import io.agora.rtm.RtmChannel;
import io.agora.rtm.RtmChannelAttribute;
import io.agora.rtm.RtmChannelListener;
import io.agora.rtm.RtmChannelMember;
import io.agora.rtm.RtmClient;
import io.agora.rtm.RtmClientListener;
import io.agora.rtm.RtmMessage;
import io.agora.rtm.SendMessageOptions;

public class AgoraRTMModule extends ReactContextBaseJavaModule
        implements RtmClientListener, RtmCallEventListener, RtmChannelListener {
    private RtmClient rtmClient;
    private RtmCallManager rtmCallManager;
    private Map<String, RtmChannel> channels;
    private Map<String, LocalInvitation> localInvitations;
    private Map<String, RemoteInvitation> remoteInvitations;

    private boolean hasListeners = false;

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

    private void startObserving() {
        hasListeners = true;
    }

    private void stopObserving() {
        hasListeners = false;
    }

    private void sendEvent(String eventName, @Nullable WritableMap params) {
        if (hasListeners) {
            getReactApplicationContext()
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(eventName, params);
        }
    }

    // init AgoraRTM instance, set event observing and init it's internal resources
    @ReactMethod
    public void init(String appId, Promise promise) {
        try {
            rtmClient = RtmClient.createInstance(getReactApplicationContext(), appId, this);
            rtmCallManager = rtmClient.getRtmCallManager();
            rtmCallManager.setEventListener(this);
            startObserving();
            promise.resolve(null);
        } catch (Exception exception) {
            promise.reject(exception);
        }
    }

    // destroy AgoraRTM instance, remove event observing and it's internal resources
    @ReactMethod
    public void destroy(Promise promise) {
        stopObserving();
        localInvitations.clear();
        remoteInvitations.clear();
        for (Map.Entry<String, RtmChannel> entry : channels.entrySet()) {
            entry.getValue().release();
        }
        channels.clear();
        rtmCallManager = null;
        rtmClient.release();
        rtmClient = null;
        promise.resolve(null);
    }

    // get sdk version
    @ReactMethod
    public void getSdkVersion(Callback callback) {
        callback.invoke(RtmClient.getSdkVersion());
    }

    // set sdk log
    @ReactMethod
    public void setSdkLog(String path, Integer level, Integer size, Promise promise) {
        int setpath = rtmClient.setLogFile(path);
        int setlevel = rtmClient.setLogFilter(level);
        int setsize = rtmClient.setLogFileSize(size);

        WritableMap data = Arguments.createMap();
        data.putBoolean("path", setpath == 0);
        data.putBoolean("size", setsize == 0);
        data.putBoolean("level", setlevel == 0);
        promise.resolve(data);
    }

    // login
    @ReactMethod
    public void login(ReadableMap params, Promise promise) {
        String token = null, uid = null;
        if (params.hasKey("token"))
            token = params.getString("token");
        if (params.hasKey("uid"))
            uid = params.getString("uid");

        rtmClient.login(token, uid, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void args) {
                promise.resolve(null);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // logout
    @ReactMethod
    public void logout(Promise promise) {
        rtmClient.logout(new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void args) {
                promise.resolve(null);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // renewToken
    @ReactMethod
    public void renewToken(String token, Promise promise) {
        rtmClient.renewToken(token, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                promise.resolve(null);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // sendMessageToPeer
    @ReactMethod
    public void sendMessageToPeer(ReadableMap params, Promise promise) {
        boolean offline = false;
        String text = null, peerId = null;
        if (params.hasKey("offline"))
            offline = params.getBoolean("offline");
        if (params.hasKey("text"))
            text = params.getString("text");
        if (params.hasKey("peerId"))
            peerId = params.getString("peerId");

        SendMessageOptions options = new SendMessageOptions();
        options.enableOfflineMessaging = offline;
        RtmMessage message = rtmClient.createMessage(text);
        rtmClient.sendMessageToPeer(peerId, message, options, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void args) {
                promise.resolve(null);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // join channel
    @ReactMethod
    public void joinChannel(String channelId, Promise promise) {
        RtmChannel rtmChannel = rtmClient.createChannel(channelId, this);
        if (rtmChannel == null) {
            promise.reject("-1", "channel_create_failed");
        } else {
            rtmChannel.join(new ResultCallback<Void>() {
                @Override
                public void onSuccess(Void aVoid) {
                    promise.resolve(null);
                }

                @Override
                public void onFailure(ErrorInfo errorInfo) {
                    promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
                }
            });
            channels.put(channelId, rtmChannel);
        }
    }

    // leave channel
    @ReactMethod
    public void leaveChannel(String channelId, Promise promise) {
        RtmChannel rtmChannel = channels.get(channelId);
        if (rtmChannel == null) {
            promise.reject("-1", "channel_not_found");
        } else {
            rtmChannel.leave(new ResultCallback<Void>() {
                @Override
                public void onSuccess(Void aVoid) {
                    rtmChannel.release();
                    channels.remove(channelId);
                    promise.resolve(null);
                }

                @Override
                public void onFailure(ErrorInfo errorInfo) {
                    promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
                }
            });
        }
    }

    // get channel members by channelId
    @ReactMethod
    public void getChannelMembersBychannelId(String channelId, Promise promise) {
        RtmChannel rtmChannel = channels.get(channelId);
        if (rtmChannel == null) {
            promise.reject("-1", "channel_not_found");
        } else {
            rtmChannel.getMembers(new ResultCallback<List<RtmChannelMember>>() {
                @Override
                public void onSuccess(List<RtmChannelMember> rtmChannelMembers) {
                    WritableArray exportMembers = Arguments.createArray();
                    for (RtmChannelMember member : rtmChannelMembers) {
                        WritableMap memberData = Arguments.createMap();
                        memberData.putString("uid", member.getUserId());
                        memberData.putString("channelId", member.getChannelId());
                        exportMembers.pushMap(memberData);
                    }
                    WritableMap params = Arguments.createMap();
                    params.putArray("members", exportMembers);
                    promise.resolve(params);
                }

                @Override
                public void onFailure(ErrorInfo errorInfo) {
                    promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
                }
            });
        }
    }

    // send channel message by channel id
    @ReactMethod
    public void sendMessageByChannelId(ReadableMap params, Promise promise) {
        String channelId = null, text = null;
        if (params.hasKey("channelId"))
            channelId = params.getString("channelId");
        if (params.hasKey("text"))
            text = params.getString("text");

        RtmChannel rtmChannel = channels.get(channelId);
        if (rtmChannel == null) {
            promise.reject("-1", "channel_not_found");
        } else {
            RtmMessage rtmMessage = rtmClient.createMessage(text);
            rtmChannel.sendMessage(rtmMessage, new ResultCallback<Void>() {
                @Override
                public void onSuccess(Void aVoid) {
                    promise.resolve(null);
                }

                @Override
                public void onFailure(ErrorInfo errorInfo) {
                    promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
                }
            });
        }
    }

    // query peer online status with ids
    @ReactMethod
    public void queryPeersOnlineStatus(ReadableMap params, Promise promise) {
        Set<String> ids = new HashSet<String>() {{
            if (params.hasKey("ids")) {
                ReadableArray ids = params.getArray("ids");
                if (ids != null) {
                    for (int i = 0; i < ids.size(); i++) {
                        add(ids.getString(i));
                    }
                }
            }
        }};

        rtmClient.queryPeersOnlineStatus(ids, new ResultCallback<Map<String, Boolean>>() {
            @Override
            public void onSuccess(Map<String, Boolean> result) {
                if (result == null) return;

                WritableArray items = Arguments.createArray();
                for (String key : result.keySet()) {
                    WritableMap item = Arguments.createMap();
                    item.putBoolean("online", result.get(key));
                    item.putString("uid", key);
                    items.pushMap(item);
                }
                WritableMap params = Arguments.createMap();
                params.putArray("items", items);
                promise.resolve(params);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // setup local user attributes
    @ReactMethod
    public void setLocalUserAttributes(ReadableMap params, Promise promise) {
        List<RtmAttribute> attributes = new LinkedList<RtmAttribute>() {{
            if (params.hasKey("attributes")) {
                ReadableArray attributes = params.getArray("attributes");
                for (int i = 0; i < attributes.size(); i++) {
                    ReadableMap attribute = attributes.getMap(i);
                    RtmAttribute rtmAttribute = new RtmAttribute();
                    rtmAttribute.setKey(attribute.getString("key"));
                    rtmAttribute.setValue(attribute.getString("value"));
                    add(rtmAttribute);
                }
            }
        }};

        rtmClient.setLocalUserAttributes(attributes, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                promise.resolve(null);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // replace local user attributes
    @ReactMethod
    public void replaceLocalUserAttributes(ReadableMap params, Promise promise) {
        List<RtmAttribute> attributes = new LinkedList<RtmAttribute>() {{
            if (params.hasKey("attributes")) {
                ReadableArray attributes = params.getArray("attributes");
                for (int i = 0; i < attributes.size(); i++) {
                    ReadableMap attribute = attributes.getMap(i);
                    RtmAttribute rtmAttribute = new RtmAttribute();
                    rtmAttribute.setKey(attribute.getString("key"));
                    rtmAttribute.setValue(attribute.getString("value"));
                    add(rtmAttribute);
                }
            }
        }};

        rtmClient.addOrUpdateLocalUserAttributes(attributes, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                promise.resolve(null);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // remove local user attributes by keys
    @ReactMethod
    public void removeLocalUserAttributesByKeys(ReadableMap params, Promise promise) {
        List<String> keys = new LinkedList<String>() {{
            if (params.hasKey("keys")) {
                ReadableArray keys = params.getArray("keys");
                for (int i = 0; i < keys.size(); i++) {
                    add(keys.getString(i));
                }
            }
        }};

        rtmClient.deleteLocalUserAttributesByKeys(keys, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                promise.resolve(null);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // remove all local user attributes
    @ReactMethod
    public void removeAllLocalUserAttributes(Promise promise) {
        rtmClient.clearLocalUserAttributes(new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                promise.resolve(null);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // get local user attributes by uid
    @ReactMethod
    public void getUserAttributesByUid(String userId, Promise promise) {
        rtmClient.getUserAttributes(userId, new ResultCallback<List<RtmAttribute>>() {
            @Override
            public void onSuccess(List<RtmAttribute> rtmAttributes) {
                WritableMap exportAttributes = Arguments.createMap();
                for (RtmAttribute attribute : rtmAttributes) {
                    exportAttributes.putString(attribute.getKey(), attribute.getValue());
                }
                WritableMap data = Arguments.createMap();
                data.putString("uid", userId);
                data.putMap("attributes", exportAttributes);
                promise.resolve(data);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // send local invitation
    @ReactMethod
    public void sendLocalInvitation(ReadableMap params, Promise promise) {
        String calleeId = null, content = null, channelId = null;
        if (params.hasKey("uid"))
            calleeId = params.getString("uid");
        if (params.hasKey("content"))
            content = params.getString("content");
        if (params.hasKey("channelId"))
            channelId = params.getString("channelId");

        LocalInvitation localInvitation = rtmCallManager.createLocalInvitation(calleeId);
        localInvitation.setContent(content);
        localInvitation.setChannelId(channelId);

        String finalCalleeId = calleeId;
        rtmCallManager.sendLocalInvitation(localInvitation, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                localInvitations.put(finalCalleeId, localInvitation);
                promise.resolve(null);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // cancel local invitation
    @ReactMethod
    public void cancelLocalInvitation(ReadableMap params, Promise promise) {
        String calleeId = null;
        if (params.hasKey("uid"))
            calleeId = params.getString("uid");

        LocalInvitation localInvitation = localInvitations.get(calleeId);
        if (localInvitation == null) {
            promise.reject("-1", "local_invitation_not_found");
        } else {
            String finalCalleeId = calleeId;
            rtmCallManager.cancelLocalInvitation(localInvitation, new ResultCallback<Void>() {
                @Override
                public void onSuccess(Void aVoid) {
                    localInvitations.remove(finalCalleeId);
                    promise.resolve(null);
                }

                @Override
                public void onFailure(ErrorInfo errorInfo) {
                    promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
                }
            });
        }
    }

    // accept remote invitation
    @ReactMethod
    public void acceptRemoteInvitation(ReadableMap params, Promise promise) {
        String callerId = null, response = null;
        if (params.hasKey("uid"))
            callerId = params.getString("uid");
        if (params.hasKey("response"))
            response = params.getString("response");

        RemoteInvitation remoteInvitation = remoteInvitations.get(callerId);
        if (remoteInvitation == null) {
            promise.reject("-1", "remote_invitation_not_found");
        } else {
            remoteInvitation.setResponse(response);

            String finalCallerId = callerId;
            rtmCallManager.acceptRemoteInvitation(remoteInvitation, new ResultCallback<Void>() {
                @Override
                public void onSuccess(Void aVoid) {
                    remoteInvitations.remove(finalCallerId);
                    promise.resolve(null);
                }

                @Override
                public void onFailure(ErrorInfo errorInfo) {
                    promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
                }
            });
        }
    }

    // refuse remote invitation
    @ReactMethod
    public void refuseRemoteInvitation(ReadableMap params, Promise promise) {
        String callerId = null, response = null;
        if (params.hasKey("uid"))
            callerId = params.getString("uid");
        if (params.hasKey("response"))
            response = params.getString("response");

        RemoteInvitation remoteInvitation = remoteInvitations.get(callerId);
        if (remoteInvitation == null) {
            promise.reject("-1", "remote_invitation_not_found");
        } else {
            remoteInvitation.setResponse(response);

            String finalCallerId = callerId;
            rtmCallManager.refuseRemoteInvitation(remoteInvitation, new ResultCallback<Void>() {
                @Override
                public void onSuccess(Void aVoid) {
                    remoteInvitations.remove(finalCallerId);
                    promise.resolve(null);
                }

                @Override
                public void onFailure(ErrorInfo errorInfo) {
                    promise.reject(String.valueOf(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
                }
            });
        }
    }

    /* RtmClientListener */

    @Override
    public void onConnectionStateChanged(int state, int reason) {
        WritableMap params = Arguments.createMap();
        params.putInt("state", state);
        params.putInt("reason", reason);
        sendEvent(AgoraRTMConstants.AG_CONNECTIONSTATECHANGED,
                params);
    }

    @Override
    public void onMessageReceived(RtmMessage rtmMessage, String peerId) {
        WritableMap params = Arguments.createMap();
        params.putString("text", rtmMessage.getText());
        params.putString("ts", Long.toString(rtmMessage.getServerReceivedTs()));
        params.putBoolean("offline", rtmMessage.isOfflineMessage());
        params.putString("peerId", peerId);
        sendEvent(AgoraRTMConstants.AG_MESSAGERECEIVED, params);
    }

    @Override
    public void onTokenExpired() {
        sendEvent(AgoraRTMConstants.AG_TOKEN_EXPIRED, null);
    }

    @Override
    public void onPeersOnlineStatusChanged(Map<String, Integer> map) {

    }

    /* RtmChannelListener */

    @Override
    public void onMemberJoined(RtmChannelMember rtmChannelMember) {
        WritableMap message = Arguments.createMap();
        message.putString("channelId", rtmChannelMember.getChannelId());
        message.putString("uid", rtmChannelMember.getUserId());
        sendEvent(AgoraRTMConstants.AG_CHANNELMEMBERJOINED, message);
    }

    @Override
    public void onMemberLeft(RtmChannelMember rtmChannelMember) {
        WritableMap message = Arguments.createMap();
        message.putString("channelId", rtmChannelMember.getChannelId());
        message.putString("uid", rtmChannelMember.getUserId());
        sendEvent(AgoraRTMConstants.AG_CHANNELMEMBERLEFT, message);
    }

    @Override
    public void onMessageReceived(RtmMessage rtmMessage, RtmChannelMember rtmChannelMember) {
        WritableMap message = Arguments.createMap();
        String uid = rtmChannelMember.getUserId();
        message.putString("channelId", rtmChannelMember.getChannelId());
        message.putString("uid", uid);
        message.putString("text", rtmMessage.getText());
        message.putDouble("ts", rtmMessage.getServerReceivedTs());
        message.putBoolean("offline", rtmMessage.isOfflineMessage());
        sendEvent(AgoraRTMConstants.AG_CHANNELMESSAGERECEVIED, message);
    }

    @Override
    public void onAttributesUpdated(List<RtmChannelAttribute> list) {

    }

    @Override
    public void onMemberCountUpdated(int i) {

    }

    /* RtmCallEventListener */

    @Override
    public void onLocalInvitationReceivedByPeer(LocalInvitation localInvitation) {
        WritableMap params = Arguments.createMap();
        params.putString("calleeId", localInvitation.getCalleeId());
        params.putString("content", localInvitation.getContent());
        params.putInt("state", localInvitation.getState());
        params.putString("channelId", localInvitation.getChannelId());
        params.putString("response", localInvitation.getResponse());
        sendEvent(AgoraRTMConstants.AG_LOCALINVITATIONRECEIVEDBYPEER, params);
    }

    @Override
    public void onLocalInvitationAccepted(LocalInvitation localInvitation, String response) {
        WritableMap params = Arguments.createMap();
        params.putString("calleeId", localInvitation.getCalleeId());
        params.putString("content", localInvitation.getContent());
        params.putInt("state", localInvitation.getState());
        params.putString("channelId", localInvitation.getChannelId());
        params.putString("response", response);
        sendEvent(AgoraRTMConstants.AG_LOCALINVITATIONACCEPTED, params);
    }

    @Override
    public void onLocalInvitationRefused(LocalInvitation localInvitation, String response) {
        WritableMap params = Arguments.createMap();
        params.putString("calleeId", localInvitation.getCalleeId());
        params.putString("content", localInvitation.getContent());
        params.putInt("state", localInvitation.getState());
        params.putString("channelId", localInvitation.getChannelId());
        params.putString("response", response);
        sendEvent(AgoraRTMConstants.AG_LOCALINVITATIONREFUSED, params);
    }

    @Override
    public void onLocalInvitationCanceled(LocalInvitation localInvitation) {
        WritableMap params = Arguments.createMap();
        params.putString("calleeId", localInvitation.getCalleeId());
        params.putString("content", localInvitation.getContent());
        params.putInt("state", localInvitation.getState());
        params.putString("channelId", localInvitation.getChannelId());
        params.putString("response", localInvitation.getResponse());
        sendEvent(AgoraRTMConstants.AG_LOCALINVITATIONCANCELED, params);
    }

    @Override
    public void onLocalInvitationFailure(LocalInvitation localInvitation, int code) {
        WritableMap params = Arguments.createMap();
        params.putString("calleeId", localInvitation.getCalleeId());
        params.putString("content", localInvitation.getContent());
        params.putInt("state", localInvitation.getState());
        params.putString("channelId", localInvitation.getChannelId());
        params.putString("response", localInvitation.getResponse());
        params.putInt("code", code);
        sendEvent(AgoraRTMConstants.AG_LOCALINVITATIONFAILURE, params);
    }

    @Override
    public void onRemoteInvitationReceived(RemoteInvitation remoteInvitation) {
        remoteInvitations.put(remoteInvitation.getCallerId(), remoteInvitation);

        WritableMap params = Arguments.createMap();
        params.putString("callerId", remoteInvitation.getCallerId());
        params.putString("content", remoteInvitation.getContent());
        params.putInt("state", remoteInvitation.getState());
        params.putString("channelId", remoteInvitation.getChannelId());
        params.putString("response", remoteInvitation.getResponse());
        sendEvent(AgoraRTMConstants.AG_REMOTEINVITATIONRECEIVED, params);
    }

    @Override
    public void onRemoteInvitationRefused(RemoteInvitation remoteInvitation) {
        WritableMap params = Arguments.createMap();
        params.putString("callerId", remoteInvitation.getCallerId());
        params.putString("content", remoteInvitation.getContent());
        params.putInt("state", remoteInvitation.getState());
        params.putString("channelId", remoteInvitation.getChannelId());
        params.putString("response", remoteInvitation.getResponse());
        sendEvent(AgoraRTMConstants.AG_REMOTEINVITATIONREFUSED, params);
    }

    @Override
    public void onRemoteInvitationAccepted(RemoteInvitation remoteInvitation) {
        WritableMap params = Arguments.createMap();
        params.putString("callerId", remoteInvitation.getCallerId());
        params.putString("content", remoteInvitation.getContent());
        params.putInt("state", remoteInvitation.getState());
        params.putString("channelId", remoteInvitation.getChannelId());
        params.putString("response", remoteInvitation.getResponse());
        sendEvent(AgoraRTMConstants.AG_REMOTEINVITATIONACCEPTED, params);
    }

    @Override
    public void onRemoteInvitationCanceled(RemoteInvitation remoteInvitation) {
        WritableMap params = Arguments.createMap();
        params.putString("callerId", remoteInvitation.getCallerId());
        params.putString("content", remoteInvitation.getContent());
        params.putInt("state", remoteInvitation.getState());
        params.putString("channelId", remoteInvitation.getChannelId());
        params.putString("response", remoteInvitation.getResponse());
        sendEvent(AgoraRTMConstants.AG_REMOTEINVITATIONCANCELED, params);
    }

    @Override
    public void onRemoteInvitationFailure(RemoteInvitation remoteInvitation, int code) {
        WritableMap params = Arguments.createMap();
        params.putString("callerId", remoteInvitation.getCallerId());
        params.putString("content", remoteInvitation.getContent());
        params.putInt("state", remoteInvitation.getState());
        params.putString("channelId", remoteInvitation.getChannelId());
        params.putString("response", remoteInvitation.getResponse());
        params.putInt("code", code);
        sendEvent(AgoraRTMConstants.AG_REMOTEINVITATIONFAILURE, params);
    }
}
