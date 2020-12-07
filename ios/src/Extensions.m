//
//  Extensions.m
//  AgoraRTM
//
//  Created by LXH on 2020/12/6.
//

#import "Extensions.h"

@implementation Extensions

+ (AgoraRtmMessage *)mapToRtmMessage:(NSDictionary *)map {
  return [[AgoraRtmMessage alloc] initWithText:map[@"message"][@"text"]];
}

+ (AgoraRtmSendMessageOptions *)mapToSendMessageOptions:(NSDictionary *)map {
  AgoraRtmSendMessageOptions *options =
      [[AgoraRtmSendMessageOptions alloc] init];
  options.enableOfflineMessaging = map[@"enableOfflineMessaging"];
  options.enableHistoricalMessaging = map[@"enableHistoricalMessaging"];
  return options;
}

+ (NSArray<NSString *> *)mapToPeerIds:(NSDictionary *)map {
  NSMutableArray *ret = [NSMutableArray new];
  NSArray<NSString *> *peerIds = map[@"peerIds"];
  for (NSString *item in peerIds) {
    [ret addObject:item];
  }
  return ret;
}

+ (NSArray<AgoraRtmAttribute *> *)mapToUserAttributes:(NSDictionary *)map {
  NSMutableArray *ret = [NSMutableArray new];
  NSArray<NSDictionary *> *attributes = map[@"attributes"];
  for (NSDictionary *item in attributes) {
    AgoraRtmAttribute *attribute = [AgoraRtmAttribute new];
    attribute.key = item[@"key"];
    attribute.value = item[@"value"];
    [ret addObject:attribute];
  }
  return ret;
}

+ (NSArray<NSString *> *)mapToAttributeKeys:(NSDictionary *)map {
  NSMutableArray *ret = [NSMutableArray new];
  NSArray<NSString *> *attributes = map[@"attributeKeys"];
  for (NSString *item in attributes) {
    [ret addObject:item];
  }
  return ret;
}

+ (NSArray<AgoraRtmChannelAttribute *> *)mapToChannelAttributes:
    (NSDictionary *)map {
  NSMutableArray *ret = [NSMutableArray new];
  NSArray<NSDictionary *> *attributes = map[@"attributes"];
  for (NSDictionary *item in attributes) {
    AgoraRtmChannelAttribute *attribute = [AgoraRtmChannelAttribute new];
    attribute.key = item[@"key"];
    attribute.value = item[@"value"];
    [ret addObject:attribute];
  }
  return ret;
}

+ (AgoraRtmChannelAttributeOptions *)mapToChannelAttributeOptions:
    (NSDictionary *)map {
  AgoraRtmChannelAttributeOptions *ret = [AgoraRtmChannelAttributeOptions new];
  ret.enableNotificationToChannelMembers =
      map[@"option"][@"enableNotificationToChannelMembers"];
  return ret;
}

+ (AgoraRtmLocalInvitation *)mapToLocalInvitation:(NSDictionary *)map {
  AgoraRtmLocalInvitation *ret =
      [[AgoraRtmLocalInvitation alloc] initWithCalleeId:map[@"calleeId"]];
  ret.content = map[@"content"];
  ret.channelId = map[@"channelId"];
  return ret;
}

+ (NSDictionary *)rtmMessageToMap:(AgoraRtmMessage *)message {
  NSMutableDictionary *ret = [NSMutableDictionary new];
  ret[@"text"] = message.text;
  ret[@"messageType"] = @(message.type);
  ret[@"serverReceivedTs"] = @(message.serverReceivedTs);
  ret[@"isOfflineMessage"] = @(message.isOfflineMessage);
  return ret;
}

+ (NSDictionary *)rtmMemberToMap:(AgoraRtmMember *)member {
  NSMutableDictionary *ret = [NSMutableDictionary new];
  ret[@"userId"] = member.userId;
  ret[@"channelId"] = member.channelId;
  return ret;
}

+ (NSDictionary *)localInvitationToMap:
    (AgoraRtmLocalInvitation *)localInvitation {
  NSMutableDictionary *ret = [NSMutableDictionary new];
  ret[@"calleeId"] = localInvitation.calleeId;
  ret[@"content"] = localInvitation.content;
  ret[@"channelId"] = localInvitation.channelId;
  ret[@"response"] = localInvitation.response;
  ret[@"state"] = @(localInvitation.state);
  ret[@"hash"] = @(localInvitation.hash);
  return ret;
}

+ (NSDictionary *)remoteInvitationToMap:
    (AgoraRtmRemoteInvitation *)remoteInvitation {
  NSMutableDictionary *ret = [NSMutableDictionary new];
  ret[@"callerId"] = remoteInvitation.callerId;
  ret[@"content"] = remoteInvitation.content;
  ret[@"channelId"] = remoteInvitation.channelId;
  ret[@"response"] = remoteInvitation.response;
  ret[@"state"] = @(remoteInvitation.state);
  ret[@"hash"] = @(remoteInvitation.hash);
  return ret;
}

+ (NSDictionary *)rtmAttributeToMap:(AgoraRtmAttribute *)attribute {
  NSMutableDictionary *ret = [NSMutableDictionary new];
  ret[@"key"] = attribute.key;
  ret[@"value"] = attribute.value;
  return ret;
}

+ (NSDictionary *)rtmChannelAttributeToMap:
    (AgoraRtmChannelAttribute *)attribute {
  NSMutableDictionary *ret = [NSMutableDictionary new];
  ret[@"key"] = attribute.key;
  ret[@"value"] = attribute.value;
  return ret;
}

@end
