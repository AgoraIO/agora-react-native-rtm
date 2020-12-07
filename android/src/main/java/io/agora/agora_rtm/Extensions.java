package io.agora.agora_rtm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.Nonnull;

import io.agora.rtm.ChannelAttributeOptions;
import io.agora.rtm.LocalInvitation;
import io.agora.rtm.RemoteInvitation;
import io.agora.rtm.RtmAttribute;
import io.agora.rtm.RtmCallManager;
import io.agora.rtm.RtmChannelAttribute;
import io.agora.rtm.RtmChannelMember;
import io.agora.rtm.RtmClient;
import io.agora.rtm.RtmMessage;
import io.agora.rtm.SendMessageOptions;

public class Extensions {
  public static String getString(Map<?, ?> map, String key) {
    if (map.containsKey(key)) {
      Object ret = map.get(key);
      if (ret instanceof String) {
        return (String) ret;
      }
    }
    return null;
  }

  public static int getInt(Map<?, ?> map, String key) {
    if (map.containsKey(key)) {
      Object ret = map.get(key);
      if (ret instanceof Number) {
        return ((Number) ret).intValue();
      }
    }
    return 0;
  }

  public static boolean getBoolean(Map<?, ?> map, String key) {
    if (map.containsKey(key)) {
      Object ret = map.get(key);
      if (ret instanceof Boolean) {
        return (Boolean) ret;
      }
    }
    return false;
  }

  public static Map<?, ?> getMap(Map<?, ?> map, String key) {
    if (map.containsKey(key)) {
      Object ret = map.get(key);
      if (ret instanceof Map) {
        return (Map<?, ?>) ret;
      }
    }
    return new HashMap<>();
  }

  public static List<?> getArray(Map<?, ?> map, String key) {
    if (map.containsKey(key)) {
      Object ret = map.get(key);
      if (ret instanceof List) {
        return (List<?>) ret;
      }
    }
    return new ArrayList<>();
  }

  public static RtmMessage mapToRtmMessage(Map<?, ?> map, @Nonnull RtmClient rtmClient) {
    Map<?, ?> message = getMap(map, "message");
    return rtmClient.createMessage(getString(message, "text"));
  }

  public static SendMessageOptions mapToSendMessageOptions(Map<?, ?> map) {
    return new SendMessageOptions() {{
      Map<?, ?> options = getMap(map, "options");
      enableOfflineMessaging = getBoolean(options, "enableOfflineMessaging");
      enableHistoricalMessaging = getBoolean(options, "enableHistoricalMessaging");
    }};
  }

  public static Set<String> mapToPeerIds(Map<?, ?> map) {
    return new HashSet<String>() {{
      List<?> peerIds = getArray(map, "peerIds");
      for (Object item : peerIds) {
        if (item instanceof String) {
          add((String) item);
        }
      }
    }};
  }

  public static List<RtmAttribute> mapToUserAttributes(Map<?, ?> map) {
    return new ArrayList<RtmAttribute>() {{
      List<?> attributes = getArray(map, "attributes");
      for (int i = 0; i < attributes.size(); i++) {
        Object attribute = attributes.get(i);
        if (attribute instanceof Map) {
          add(new RtmAttribute(getString((Map<?, ?>) attribute, "key"), getString((Map<?, ?>) attribute, "value")));
        }
      }
    }};
  }

  public static List<String> mapToAttributeKeys(Map<?, ?> map) {
    return new ArrayList<String>() {{
      List<?> attributeKeys = getArray(map, "attributeKeys");
      for (int i = 0; i < attributeKeys.size(); i++) {
        for (Object item : attributeKeys) {
          if (item instanceof String) {
            add((String) item);
          }
        }
      }
    }};
  }

  public static List<RtmChannelAttribute> mapToChannelAttributes(Map<?, ?> map) {
    return new ArrayList<RtmChannelAttribute>() {{
      List<?> attributes = getArray(map, "attributes");
      for (int i = 0; i < attributes.size(); i++) {
        Object attribute = attributes.get(i);
        if (attribute instanceof Map) {
          add(new RtmChannelAttribute(getString((Map<?, ?>) attribute, "key"), getString((Map<?, ?>) attribute, "value")));
        }
      }
    }};
  }

  public static ChannelAttributeOptions mapToChannelAttributeOptions(Map<?, ?> map) {
    return new ChannelAttributeOptions(getBoolean(getMap(map, "option"), "enableNotificationToChannelMembers"));
  }

  public static LocalInvitation mapToLocalInvitation(Map<?, ?> map, @Nonnull RtmCallManager rtmCallManager) {
    LocalInvitation ret = rtmCallManager.createLocalInvitation(getString(map, "calleeId"));
    ret.setContent(getString(map, "content"));
    ret.setChannelId(getString(map, "channelId"));
    return ret;
  }

  public static Map<String, Object> toMap(RtmMessage message) {
    return new HashMap<String, Object>() {{
      put("text", message.getText());
      put("messageType", message.getMessageType());
      put("serverReceivedTs", message.getServerReceivedTs());
      put("isOfflineMessage", message.isOfflineMessage());
    }};
  }

  public static Map<String, Object> toMap(RtmChannelMember member) {
    return new HashMap<String, Object>() {{
      put("userId", member.getUserId());
      put("channelId", member.getChannelId());
    }};
  }

  public static Map<String, Object> toMap(LocalInvitation localInvitation) {
    return new HashMap<String, Object>() {{
      put("calleeId", localInvitation.getCalleeId());
      put("content", localInvitation.getContent());
      put("channelId", localInvitation.getChannelId());
      put("response", localInvitation.getResponse());
      put("state", localInvitation.getState());
      put("hash", System.identityHashCode(localInvitation));
    }};
  }

  public static Map<String, Object> toMap(RemoteInvitation remoteInvitation) {
    return new HashMap<String, Object>() {{
      put("callerId", remoteInvitation.getCallerId());
      put("content", remoteInvitation.getContent());
      put("channelId", remoteInvitation.getChannelId());
      put("response", remoteInvitation.getResponse());
      put("state", remoteInvitation.getState());
      put("hash", System.identityHashCode(remoteInvitation));
    }};
  }

  public static Map<String, Object> toMap(RtmAttribute attribute) {
    return new HashMap<String, Object>() {{
      put("key", attribute.getKey());
      put("value", attribute.getValue());
    }};
  }

  public static Map<String, Object> toMap(RtmChannelAttribute attribute) {
    return new HashMap<String, Object>() {{
      put("key", attribute.getKey());
      put("value", attribute.getValue());
      put("lastUpdateUserId", attribute.getLastUpdateUserId());
      put("lastUpdateTs", attribute.getLastUpdateTs());
    }};
  }
}
