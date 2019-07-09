package io.agora.agora_rtm;

import android.support.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
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

import io.agora.rtm.ErrorInfo;
import io.agora.rtm.LocalInvitation;
import io.agora.rtm.RemoteInvitation;
import io.agora.rtm.ResultCallback;
import io.agora.rtm.RtmAttribute;
import io.agora.rtm.RtmCallEventListener;
import io.agora.rtm.RtmCallManager;
import io.agora.rtm.RtmChannel;
import io.agora.rtm.RtmChannelListener;
import io.agora.rtm.RtmChannelMember;
import io.agora.rtm.RtmClient;
import io.agora.rtm.RtmClientListener;
import io.agora.rtm.RtmMessage;
import io.agora.rtm.SendMessageOptions;

public class AgoraRTMModule extends ReactContextBaseJavaModule
        implements RtmClientListener, RtmCallEventListener, RtmChannelListener {

    private Map<String, LocalInvitation> localInvitations = new HashMap<>();
    private Map<String, RemoteInvitation> remoteInvitations = new HashMap<>();
    private Map<String, RtmChannel> channels = new HashMap<>();

    private RtmClient rtmClient;
    private RtmCallManager rtmCallManager;

    private boolean hasListeners = false;

    private void startObserving () {
        hasListeners = true;
    }

    private void stopObserving () {
        hasListeners = false;
    }

    private void sendEvent(String eventName,
                           @Nullable WritableMap params) {
        if (hasListeners) {
            getReactApplicationContext()
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(eventName, params);
        }
    }

    public AgoraRTMModule(ReactApplicationContext ctx) {
        super(ctx);
    }

    @Override
    public String getName() {
        return "AgoraRTM";
    }

    // init AgoraRTM instance, set event observing and init it's internal resources
    @ReactMethod
    public void init(String appID) {
        try {
            rtmClient = RtmClient.createInstance(getReactApplicationContext(), appID, this);
            rtmCallManager = rtmClient.getRtmCallManager();
            rtmCallManager.setEventListener(this);
            startObserving();
        } catch (Exception exception) {
            WritableMap params = Arguments.createMap();
            params.putString("api", "init");
            params.putString("message", exception.getMessage());
            sendEvent(AgoraRTMConstants.AG_ERROR, params);
        }
    }

    // destroy AgoraRTM instance, remove event observing and it's internal resources
    @ReactMethod
    public void destroy() {
        stopObserving();
        localInvitations.clear();
        localInvitations = null;
        remoteInvitations.clear();
        remoteInvitations = null;
        for (Map.Entry<String, RtmChannel> ite: channels.entrySet()) {
            ite.getValue().release();
        }
        channels.clear();
        channels = null;
        rtmCallManager = null;
        rtmClient.release();
        rtmClient = null;
    }

    // login
    @ReactMethod
    public void login(final ReadableMap params, final Promise promise) {
        String token = null;
        if (params.hasKey("token")) {
            token = params.getString("token");
        }
        final String userId = params.getString("uid");
        rtmClient.login(token != null ? token : null, userId, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void args) {
                promise.resolve(null);
            }
            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // logout
    @ReactMethod
    public void logout(final Promise promise) {
        rtmClient.logout(new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void args) {
                promise.resolve(null);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // renewToken
    @ReactMethod
    public void renewToken(final String token, final Promise promise) {
        rtmClient.renewToken(token, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                promise.resolve(aVoid);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // sendMessageToPeer
    @ReactMethod
    public void sendMessageToPeer(final ReadableMap params, final Promise promise) {
        RtmMessage rtmMessage = rtmClient.createMessage();
        String peerId = params.getString("peerId");
        String message = params.getString("text");
        Boolean enableOffline = params.getBoolean("offline");
        SendMessageOptions options = new SendMessageOptions();
        options.enableOfflineMessaging = enableOffline;
        rtmMessage.setText(message);
        rtmClient.sendMessageToPeer(peerId, rtmMessage, options, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void args) {
                promise.resolve(args);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // join channel
    @ReactMethod
    public void joinChannel(final String channelId, final Promise promise) {
        final RtmChannel rtmChannel = rtmClient.createChannel(channelId, this);
        if (null == rtmChannel) {
            promise.reject("-1", "channel_create_failed");
        } else {
            rtmChannel.join(new ResultCallback<Void>() {
                @Override
                public void onSuccess(Void aVoid) {
                    channels.put(channelId, rtmChannel);
                    promise.resolve(null);
                }

                @Override
                public void onFailure(ErrorInfo errorInfo) {
                    promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
                }
            });
        }
    }

    // leave channel
    @ReactMethod
    public void leaveChannel(final String channelId, final Promise promise) {
        final RtmChannel rtmChannel = channels.get(channelId);
        if (null == rtmChannel) {
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
                    promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
                }
            });
        }
    }

    // get channel members by channelId
    @ReactMethod
    public void getChannelMembersBychannelId(final String channelId, final Promise promise) {
        RtmChannel rtmChannel = channels.get(channelId);
        if (null == rtmChannel) {
            promise.reject("-1", "channel_not_found");
        } else {
            rtmChannel.getMembers(new ResultCallback<List<RtmChannelMember>>() {
                @Override
                public void onSuccess(List<RtmChannelMember> rtmChannelMembers) {
                    WritableArray members = Arguments.createArray();
                    for (RtmChannelMember member: rtmChannelMembers) {
                        WritableMap memberData = Arguments.createMap();
                        memberData.putString("uid", member.getUserId());
                        memberData.putString("channelId", member.getChannelId());
                        members.pushMap(memberData);
                    }
                    WritableMap params = Arguments.createMap();
                    params.putArray("members", members);
                    promise.resolve(params);
                }

                @Override
                public void onFailure(ErrorInfo errorInfo) {
                    promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
                }
            });
        }
    }

    // sned channel message by channel id
    @ReactMethod
    public void sendMessageByChannelId(ReadableMap params, final Promise promise) {
        final String channelId = params.getString("channelId");
        final String text = params.getString("text");
        RtmChannel rtmChannel = channels.get(channelId);

        if (null == rtmChannel) {
            promise.reject("-1", "channel_not_found");
        } else {
            RtmMessage rtmMessage = rtmClient.createMessage();
            rtmMessage.setText(text);
            rtmChannel.sendMessage(rtmMessage, new ResultCallback<Void>() {
                @Override
                public void onSuccess(Void aVoid) {
                    promise.resolve(null);
                }

                @Override
                public void onFailure(ErrorInfo errorInfo) {
                    promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
                }
            });
        }
    }

    // query peer online status with ids
    @ReactMethod
    public void queryPeersOnlineStatus(final ReadableMap params, final Promise promise) {
        final ReadableArray ids = params.getArray("ids");
        Set<String> sets = new HashSet<String>();
        for (int i = 0; i < ids.size(); i++) {
            sets.add(ids.getString(i));
        }
        rtmClient.queryPeersOnlineStatus(sets, new ResultCallback<Map<String, Boolean>>() {
            @Override
            public void onSuccess(Map<String, Boolean> result) {
                WritableArray items = Arguments.createArray();
                Set<String> keys = result.keySet();
                for (String key : keys) {
                    boolean online = result.get(key);
                    String uid = key;
                    WritableMap item = Arguments.createMap();
                    item.putString("uid", uid);
                    item.putBoolean("online", online);
                    items.pushMap(item);
                }
                WritableMap params = Arguments.createMap();
                params.putArray("items", items);
                promise.resolve(params);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }


    // setup local user attributes
    @ReactMethod
    public void setLocalUserAttributes(ReadableMap params, final Promise promise) {
        ReadableArray attributesParam = params.getArray("attributes");
        List<RtmAttribute> attributes = new LinkedList<RtmAttribute>();
        for (int i = 0; i < attributesParam.size(); i++) {
            RtmAttribute rtmAttribute = new RtmAttribute();
            ReadableMap item = attributesParam.getMap(i);
            rtmAttribute.setKey(item.getString("key"));
            rtmAttribute.setValue(item.getString("value"));
            attributes.add(rtmAttribute);
        }
        rtmClient.setLocalUserAttributes(attributes, new ResultCallback<Void> () {
            @Override
            public void onSuccess(Void aVoid) {
                promise.resolve(null);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // replace local user attributes
    @ReactMethod
    public void replaceLocalUserAttributes(ReadableMap params, final Promise promise) {
        ReadableArray attributesParam = params.getArray("attributes");
        List<RtmAttribute> attributes = new LinkedList<RtmAttribute>();
        for (int i = 0; i < attributesParam.size(); i++) {
            RtmAttribute rtmAttribute = new RtmAttribute();
            ReadableMap item = attributesParam.getMap(i);
            rtmAttribute.setKey(item.getString("key"));
            rtmAttribute.setValue(item.getString("value"));
            attributes.add(rtmAttribute);
        }
        rtmClient.addOrUpdateLocalUserAttributes(attributes, new ResultCallback<Void> () {
            @Override
            public void onSuccess(Void aVoid) {
                promise.resolve(null);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // remove local user attributes by keys
    @ReactMethod
    public void removeLocalUserAttributesByKeys(ReadableMap params, final Promise promise) {
        List<String> list = new LinkedList<>();
        ReadableArray array = params.getArray("keys");
        for (int i = 0; i < array.size(); i++) {
            list.add(array.getString(i));
        }
        rtmClient.deleteLocalUserAttributesByKeys(list, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                promise.resolve(null);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // remove all local user attributes
    @ReactMethod
    public void removeAllLocalUserAttributes(final Promise promise) {
        rtmClient.clearLocalUserAttributes(new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                promise.resolve(null);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // get local user attributes by uid
    @ReactMethod
    public void getUserAttributesByUid(final String userId, final Promise promise) {
        rtmClient.getUserAttributes(userId, new ResultCallback<List<RtmAttribute>>() {
            @Override
            public void onSuccess(List<RtmAttribute> rtmAttributes) {
                WritableMap userAttributes = Arguments.createMap();
                for (RtmAttribute attribute: rtmAttributes) {
                    userAttributes.putString(attribute.getKey(), attribute.getValue());
                }
                WritableMap data = Arguments.createMap();
                data.putString("uid", userId);
                data.putMap("attributes", userAttributes);
                promise.resolve(data);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }


    // send local invitation
    @ReactMethod
    public void sendLocalInvitation (ReadableMap params, final Promise promise) {
        final String calleeId = params.getString("uid");
        final LocalInvitation localInvitation = rtmCallManager.createLocalInvitation(calleeId);
        final String channelId = params.getString("channelId");
        String content = null;
        if(params.hasKey("content")) {
            content = params.getString("content");
            localInvitation.setContent(content);
        }
        localInvitation.setChannelId(channelId);
        rtmCallManager.sendLocalInvitation(localInvitation, new ResultCallback<Void> () {
            @Override
            public void onSuccess(Void aVoid) {
                localInvitations.put(calleeId, localInvitation);
                promise.resolve(null);
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
            }
        });
    }

    // cancel local invitation
    @ReactMethod
    public void cancelLocalInvitation (ReadableMap params, final Promise promise) {
        final String calleeId = params.getString("uid");
        if (null != localInvitations.get(calleeId)) {
            final LocalInvitation localInvitation = localInvitations.get(calleeId);
            String channelId = params.getString("channelId");
            if (params.hasKey("content")) {
                String content = params.getString("content");
                localInvitation.setContent(content);
            }
            localInvitation.setChannelId(channelId);
            rtmCallManager.cancelLocalInvitation(localInvitation, new ResultCallback<Void> () {
                @Override
                public void onSuccess(Void aVoid) {
                    localInvitations.put(calleeId, localInvitation);
                    promise.resolve(null);
                }

                @Override
                public void onFailure(ErrorInfo errorInfo) {
                    promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
                }
            });
        } else {
            promise.reject("-1", "local_invitation_not_found");
        }
    }

    // accept remote invitation
    @ReactMethod
    public void acceptRemoteInvitation (ReadableMap params, final Promise promise) {
        final String calleeId = params.getString("uid");
        if (null != remoteInvitations.get(calleeId)) {
            final RemoteInvitation remoteInvitation = remoteInvitations.get(calleeId);
            if (params.hasKey("response")) {
                final String response = params.getString("response");
                remoteInvitation.setResponse(response);
            }
            rtmCallManager.acceptRemoteInvitation(remoteInvitation, new ResultCallback<Void> () {
                @Override
                public void onSuccess(Void aVoid) {
                    remoteInvitations.remove(remoteInvitation);
                    promise.resolve(null);
                }

                @Override
                public void onFailure(ErrorInfo errorInfo) {
                    promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
                }
            });
        } else {
            promise.reject(Integer.toString(-1), "remote_invitation_not_found");
        }
    }


    // refuse remote invitation
    @ReactMethod
    public void refuseRemoteInvitation (ReadableMap params, final Promise promise) {
        final String calleeId = params.getString("uid");
        if (null != remoteInvitations.get(calleeId)) {
            final RemoteInvitation remoteInvitation = remoteInvitations.get(calleeId);
            if (params.hasKey("response")) {
                final String response = params.getString("response");
                remoteInvitation.setResponse(response);
            }
            rtmCallManager.refuseRemoteInvitation(remoteInvitation, new ResultCallback<Void> () {
                @Override
                public void onSuccess(Void aVoid) {
                    remoteInvitations.remove(remoteInvitation);
                    promise.resolve(null);
                }

                @Override
                public void onFailure(ErrorInfo errorInfo) {
                    promise.reject(Integer.toString(errorInfo.getErrorCode()), errorInfo.getErrorDescription());
                }
            });
        } else {
            promise.reject("-1", "remote_invitation_not_found");
        }
    }

    // RtmClientListener
    @Override
    public void onConnectionStateChanged(int state, int reason) {
        WritableMap params = Arguments.createMap();
        params.putInt("state", state);
        params.putInt("reason", reason);
        sendEvent(AgoraRTMConstants.AG_CONNECTIONSTATECHANGED,
                params);
    }

    // p2p message received
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
        WritableMap params = Arguments.createMap();
        params.putString("message", "token_expired");
        sendEvent(AgoraRTMConstants.AG_TOKEN_EXPIRED, params);
    }

    // RtmCallEventListener
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
        WritableMap params = Arguments.createMap();
        params.putString("callerId", remoteInvitation.getCallerId());
        params.putString("content", remoteInvitation.getContent());
        params.putInt("state", remoteInvitation.getState());
        params.putString("channelId", remoteInvitation.getChannelId());
        params.putString("response", remoteInvitation.getResponse());
        sendEvent(AgoraRTMConstants.AG_REMOTEINVITATIONRECEIVED, params);
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
        params.putInt("code", code);
        params.putString("response", remoteInvitation.getResponse());
        sendEvent(AgoraRTMConstants.AG_REMOTEINVITATIONFAILURE, params);
    }

    // RtmChannelListener
    // channel message received
    @Override
    public void onMessageReceived(RtmMessage rtmMessage, RtmChannelMember rtmChannelMember) {
        String channelId = rtmChannelMember.getChannelId();
        String ts = Long.toString(rtmMessage.getServerReceivedTs());
        String text = rtmMessage.getText();
        boolean isOffline = rtmMessage.isOfflineMessage();
        WritableMap message = Arguments.createMap();
        String uid = rtmChannelMember.getUserId();
        message.putString("channelId", channelId);
        message.putString("uid", uid);
        message.putString("text", text);
        message.putString("ts", ts);
        message.putBoolean("offline", isOffline);
        sendEvent(AgoraRTMConstants.AG_CHANNELMESSAGERECEVIED, message);
    }

    @Override
    public void onMemberJoined(RtmChannelMember rtmChannelMember) {
        String channelId = rtmChannelMember.getChannelId();
        String userId = rtmChannelMember.getUserId();
        WritableMap message = Arguments.createMap();
        message.putString("channelId", channelId);
        message.putString("uid", userId);
        sendEvent(AgoraRTMConstants.AG_CHANNELMEMBERJOINED, message);
    }

    @Override
    public void onMemberLeft(RtmChannelMember rtmChannelMember) {
        String channelId = rtmChannelMember.getChannelId();
        String userId = rtmChannelMember.getUserId();
        WritableMap message = Arguments.createMap();
        message.putString("channelId", channelId);
        message.putString("uid", userId);
        sendEvent(AgoraRTMConstants.AG_CHANNELMEMBERLEFT, message);
    }
}
