//
//  AgoraRTM.m
//  AgoraRTM
//
//  Created by Matrixbirds on 2019/5/27.
//

#import "AgoraRTM.h"
#import "AgoraConst.h"
#import <React/RCTEventDispatcher.h>
#import <React/RCTBridge.h>
#import <React/RCTView.h>

@interface AgoraRTM ()
@property (strong, nonatomic) AgoraRtmKit *rtmEngine;
@property (strong, nonatomic) AgoraRtmCallKit *rtmCallManager;
@property (strong, nonatomic) NSMutableDictionary<NSString*, AgoraRtmChannel*> *channels;
@property (strong, nonatomic) NSMutableDictionary<NSString *, AgoraRtmLocalInvitation *> *localInvitations;
@property (strong, nonatomic) NSMutableDictionary<NSString *, AgoraRtmRemoteInvitation*> *remoteInvitations;
@end

@implementation AgoraRTM {
  bool hasListeners;
}

+(BOOL)requiresMainQueueSetup {
  return YES;
}

RCT_EXPORT_MODULE();

- (void) startObserving {
  hasListeners = YES;
}

- (void) stopObserving {
  hasListeners = NO;
}

- (void) sendEvent:(NSString *)msg params:(NSDictionary *)params {
  if (hasListeners) {
    [self sendEventWithName:msg body:params];
  }
}

- (NSArray<NSString *>*) supportedEvents {
  return @[
      AG_ERROR,
      AG_CONNECTIONSTATECHANGED,
      AG_MESSAGERECEIVED,
      AG_LOCALINVITATIONRECEIVEDBYPEER,
      AG_LOCALINVITATIONACCEPTED,
      AG_LOCALINVITATIONREFUSED,
      AG_LOCALINVITATIONCANCELED,
      AG_LOCALINVITATIONFAILURE,
      AG_REMOTEINVITATIONFAILURE,
      AG_REMOTEINVITATIONRECEIVED,
      AG_REMOTEINVITATIONACCEPTED,
      AG_REMOTEINVITATIONREFUSED,
      AG_REMOTEINVITATIONCANCELED,
      AG_CHANNELMESSAGERECEVIED,
      AG_CHANNELMEMBERJOINED,
      AG_CHANNELMEMBERLEFT,
      AG_TOKEN_EXPIRED
  ];
}

// init AgoraRTM instance, set event observing and init it's internal resources
RCT_EXPORT_METHOD(init:(NSString *)appId) {
  self.rtmEngine = [[AgoraRtmKit new] initWithAppId:appId delegate:self];
  self.rtmCallManager = [[self rtmEngine] getRtmCallKit];
  self.channels = [NSMutableDictionary dictionary];
  self.localInvitations = [NSMutableDictionary dictionary];
  self.remoteInvitations = [NSMutableDictionary dictionary];
  [self startObserving];
}

// destroy AgoraRTM instance, remove event observing and it's internal resources
RCT_EXPORT_METHOD(destroy) {
  [self stopObserving];
  self.rtmCallManager = nil;
  self.rtmEngine = nil;
  for (id key in self.channels) {
    if (self.channels[key] != nil) {
      [self.rtmEngine destroyChannelWithId:key];
    }
  }
  [self.channels removeAllObjects];
  self.channels = nil;
  [self.localInvitations removeAllObjects];
  self.localInvitations = nil;
  [self.remoteInvitations removeAllObjects];
  self.remoteInvitations = nil;
}

// login
RCT_EXPORT_METHOD(login:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  NSString *token = [params objectForKey:@"token"] ? params[@"token"] : nil;
  [[self rtmEngine]loginByToken:token
                           user:params[@"uid"] completion:^(AgoraRtmLoginErrorCode errorCode) {
    if (0 != (int)errorCode) {
      reject(@(-1).stringValue, @(errorCode).stringValue, nil);
    } else {
      resolve(nil);
    }
  }];
}

// logout
RCT_EXPORT_METHOD(logout:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  [[self rtmEngine] logoutWithCompletion:^(AgoraRtmLogoutErrorCode errorCode) {
    if (0 != (int)errorCode) {
      reject(@(-1).stringValue, @(errorCode).stringValue, nil);
    } else {
      resolve(nil);
    }
  }];
}

// get sdk version
RCT_EXPORT_METHOD(getSdkVersion:(RCTResponseSenderBlock)callback) {
  callback(@[[AgoraRtmKit getSDKVersion]]);
}

// set sdk log
RCT_EXPORT_METHOD(setSdkLog:(NSString *)path
                  level:(NSInteger)level
                  size:(NSInteger)size
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  int fileSize = (int) size;
  int setpath = [_rtmEngine setLogFile:path];
  int setsize = [_rtmEngine setLogFileSize:fileSize];
  int setlevel = [_rtmEngine setLogFilters:level];

  resolve(@{
            @"path": @(setpath == 0),
            @"size": @(setsize == 0),
            @"level": @(setlevel == 0)
  });
}


// renewToken
RCT_EXPORT_METHOD(renewToken:(NSString*)token
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  [[self rtmEngine] renewToken:token completion:^(NSString *token, AgoraRtmRenewTokenErrorCode errorCode) {
    if (0 != (int)errorCode) {
      reject(@(-1).stringValue, @(errorCode).stringValue, nil);
    } else {
      resolve(nil);
    }
  }];
}

// sendMessageToPeer
RCT_EXPORT_METHOD(sendMessageToPeer:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  AgoraRtmSendMessageOptions *options = [AgoraRtmSendMessageOptions new];
  [options setEnableOfflineMessaging:[params[@"offline"] boolValue]];
  AgoraRtmMessage *msg = [[AgoraRtmMessage new] initWithText:params[@"text"]];
  [[self rtmEngine] sendMessage:msg toPeer:params[@"peerId"] sendMessageOptions:options completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
    if (0 != (int)errorCode) {
      reject(@(-1).stringValue, @(errorCode).stringValue, nil);
    } else {
      resolve(nil);
    }
  }];
}

// join channel
RCT_EXPORT_METHOD(joinChannel:(NSString *)channelId
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  AgoraRtmChannel *rtmChannel = [_rtmEngine createChannelWithId:channelId delegate:self];
  if (nil != rtmChannel){
    [rtmChannel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
      if (0 != (int)errorCode) {
        reject(@(-1).stringValue, @(errorCode).stringValue, nil);
      } else {
        [self.channels setObject:rtmChannel forKey:channelId];
        resolve(nil);
      }
    }];
  } else {
    reject(@"-1", @"channel_create_failed", nil);
  }
}

// leave channel
RCT_EXPORT_METHOD(leaveChannel:(NSString *) channelId
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  AgoraRtmChannel *rtmChannel = _channels[channelId];
  if (rtmChannel != nil) {
    [rtmChannel leaveWithCompletion:^(AgoraRtmLeaveChannelErrorCode errorCode) {
      if (0 != (int)errorCode) {
        reject(@(-1).stringValue, @(errorCode).stringValue, nil);
      } else {
        [self.channels removeObjectForKey:channelId];
        [self.rtmEngine destroyChannelWithId:channelId];
        resolve(nil);
      }
    }];
  } else {
    reject(@"-1", @"channel_not_found", nil);
  }
}

// get channel member by channel id
RCT_EXPORT_METHOD(getChannelMembersBychannelId:(NSString *)uid
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  AgoraRtmChannel *rtmChannel = _channels[uid];
  if (rtmChannel != nil) {
    [rtmChannel getMembersWithCompletion:^(NSArray<AgoraRtmMember *> * _Nullable members, AgoraRtmGetMembersErrorCode errorCode) {
      if (0 != (int)errorCode) {
        reject(@(-1).stringValue, @(errorCode).stringValue, nil);
      } else {
        NSMutableArray<NSDictionary*> *exportMembers = [NSMutableArray new];
        for(AgoraRtmMember *member in members) {
          [exportMembers addObject:@{
                                     @"uid": member.userId,
                                     @"channelId": member.channelId
                                     }];
        }
        resolve(@{
                  @"members": exportMembers
                  });
      }
    }];
  } else {
    reject(@"-1", @"channel_not_found", nil);
  }
}

// send message by channel id
RCT_EXPORT_METHOD(sendMessageByChannelId:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject){
  AgoraRtmChannel *rtmChannel = self.channels[params[@"channelId"]];
  if (rtmChannel != nil) {
    AgoraRtmMessage *message = [[AgoraRtmMessage new] initWithText:params[@"text"]];
    [rtmChannel sendMessage:message completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
      if (0 != (int)errorCode) {
        reject(@(-1).stringValue, @(errorCode).stringValue, nil);
      } else {
        resolve(nil);
      }
    }];
  } else {
    reject(@"-1", @"channel_not_found", nil);
  }
}

// query peer online status with ids
RCT_EXPORT_METHOD(queryPeersOnlineStatus:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  NSArray *ids = [params[@"ids"] allValues];
  [[self rtmEngine] queryPeersOnlineStatus:ids completion:^(NSArray<AgoraRtmPeerOnlineStatus *> *peerOnlineStatus, AgoraRtmQueryPeersOnlineErrorCode errorCode) {
    if (0 != (int)errorCode) {
      reject(@(-1).stringValue, @(errorCode).stringValue, nil);
    } else {
      NSMutableArray<NSDictionary*> *data = [NSMutableArray new];
      for(AgoraRtmPeerOnlineStatus *item in peerOnlineStatus) {
        [data addObject:@{
          @"online": @(item.isOnline),
          @"uid": item.peerId,
        }];
      }
      resolve(@{@"items": data});
    }
  }];
}

// setup local user attributes
RCT_EXPORT_METHOD(setLocalUserAttributes:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  NSArray<NSDictionary*> *attributesParam = params[@"attributes"];
  NSMutableArray<AgoraRtmAttribute*> *attributes = [[NSMutableArray<AgoraRtmAttribute*> alloc] init];
  for (NSDictionary *attribute in attributesParam) {
    AgoraRtmAttribute *attr = [[AgoraRtmAttribute alloc] init];
    attr.key = attribute[@"key"];
    attr.value = attribute[@"value"];
    [attributes addObject:attr];
  }
  [_rtmEngine setLocalUserAttributes:attributes completion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
    if (0 != (int)errorCode) {
      reject(@(-1).stringValue, @(errorCode).stringValue, nil);
    } else {
      resolve(nil);
    }
  }];
}

// replace local user attributes
RCT_EXPORT_METHOD(replaceLocalUserAttributes:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  NSArray<NSDictionary*> *attributesParam = params[@"attributes"];
  NSMutableArray<AgoraRtmAttribute*> *attributes = [[NSMutableArray<AgoraRtmAttribute*> alloc] init];
  for (NSDictionary *attribute in attributesParam) {
    AgoraRtmAttribute *attr = [[AgoraRtmAttribute alloc] init];
    attr.key = attribute[@"key"];
    attr.value = attribute[@"value"];
    [attributes addObject:attr];
  }
  [_rtmEngine addOrUpdateLocalUserAttributes:attributes completion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
    if (0 != (int)errorCode) {
      reject(@(-1).stringValue, @(errorCode).stringValue, nil);
    } else {
      resolve(nil);
    }
  }];
}

// remove local user attributes by keys
RCT_EXPORT_METHOD(removeLocalUserAttributesByKeys:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  NSArray<NSString*> *keys = params[@"keys"];
  [_rtmEngine deleteLocalUserAttributesByKeys:keys completion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
    if (0 != (int)errorCode) {
      reject(@(-1).stringValue, @(errorCode).stringValue, nil);
    } else {
      resolve(nil);
    }
  }];
}

// remove all local user attributes
RCT_EXPORT_METHOD(removeAllLocalUserAttributes:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  [_rtmEngine clearLocalUserAttributesWithCompletion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
    if (0 != (int)errorCode) {
      reject(@(-1).stringValue, @(errorCode).stringValue, nil);
    } else {
      resolve(nil);
    }
  }];
}

// get local user attributes by uid
RCT_EXPORT_METHOD(getUserAttributesByUid:(NSString *)uid
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  [_rtmEngine getUserAllAttributes:uid completion:^(NSArray<AgoraRtmAttribute *> * _Nullable attributes, NSString *userId, AgoraRtmProcessAttributeErrorCode errorCode) {
    if (0 != (int)errorCode) {
      reject(@(-1).stringValue, @(errorCode).stringValue, nil);
    } else {
      NSMutableDictionary<NSString*, NSString*> *exportAttributes = [NSMutableDictionary dictionary];
      for (AgoraRtmAttribute *item in attributes) {
        [exportAttributes setObject:item.value forKey:item.key];
      }
      resolve(@{
                @"uid": uid,
                @"attributes": exportAttributes
                });
    }
  }];
}

// send local invitation
RCT_EXPORT_METHOD(sendLocalInvitation:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  NSString *uid = params[@"uid"];
  AgoraRtmLocalInvitation *localInvitation = [[AgoraRtmLocalInvitation new] initWithCalleeId:uid];
  if ([params objectForKey:@"content"]) {
    localInvitation.content = params[@"content"];
  }
  if ([params objectForKey:@"channelId"]) {
    localInvitation.channelId = params[@"channelId"];
  }
  [_rtmCallManager sendLocalInvitation:localInvitation completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
    if (0 != (int)errorCode) {
      reject(@(-1).stringValue, @(errorCode).stringValue, nil);
    } else {
      [self.localInvitations setObject:localInvitation forKey:uid];
      resolve(nil);
    }
  }];
}

// cancel local invitation
RCT_EXPORT_METHOD(cancelLocalInvitation:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  NSString *uid = params[@"uid"];
  AgoraRtmLocalInvitation *localInvitation = _localInvitations[uid];
  if (localInvitation != nil) {
    if ([params objectForKey:@"content"]) {
      localInvitation.content = params[@"content"];
    }
    if ([params objectForKey:@"channelId"]) {
      localInvitation.channelId = params[@"channelId"];
    }
    [_rtmCallManager cancelLocalInvitation:localInvitation completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
      if (0 != (int)errorCode) {
        reject(@(-1).stringValue, @(errorCode).stringValue, nil);
      } else {
        resolve(nil);
      }
    }];
  } else {
    reject(@"-1", @"local_invitation_not_found", nil);
  }
}

// accept remote invitation
RCT_EXPORT_METHOD(acceptRemoteInvitation:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  NSString *uid = params[@"uid"];
  AgoraRtmRemoteInvitation *remoteInvitation = self.remoteInvitations[uid];
  if (remoteInvitation != nil) {
    if ([params objectForKey:@"response"]) {
      remoteInvitation.response = params[@"response"];
    }
    [_rtmCallManager acceptRemoteInvitation:remoteInvitation completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
      if (0 != (int)errorCode) {
        reject(@(-1).stringValue, @(errorCode).stringValue, nil);
      } else {
        [self.remoteInvitations removeObjectForKey:uid];
        resolve(nil);
      }
    }];
  } else {
    reject(@"-1", @"remote_invitation_not_found", nil);
  }
}

// refuse remote invitation
RCT_EXPORT_METHOD(refuseRemoteInvitation:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  NSString *uid = params[@"uid"];
  AgoraRtmRemoteInvitation *remoteInvitation = _remoteInvitations[uid];
  if (nil != remoteInvitation) {
    if ([params objectForKey:@"response"]) {
      remoteInvitation.response = params[@"response"];
    }
    [_rtmCallManager refuseRemoteInvitation:remoteInvitation completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
      if (0 != (int)errorCode) {
        reject(@(-1).stringValue, @(errorCode).stringValue, nil);
      } else {
        [self.remoteInvitations removeObjectForKey:uid];
        resolve(nil);
      }
    }];
  } else {
    reject(@"-1", @"remote_invitation_not_found", nil);
  }
}

#pragma mark - AgoraRtmDelegate

- (void)rtmKit:(AgoraRtmKit *_Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
  [self sendEvent:AG_CONNECTIONSTATECHANGED params:@{
                                                     @"state": @(state),
                                                     @"reason": @(reason)
                                                     }];
}

- (void)rtmKit:(AgoraRtmKit *_Nonnull)kit messageReceived:(AgoraRtmMessage *_Nonnull)message fromPeer:(NSString *_Nonnull)peerId {
  [self sendEvent:AG_MESSAGERECEIVED params:@{
                                                  @"text": message.text,
                                                  @"ts": @(message.serverReceivedTs),
                                                  @"offline": @(message.isOfflineMessage),
                                                  @"peerId": peerId
                                              }];
}

- (void)rtmKitTokenDidExpire:(AgoraRtmKit *_Nonnull)kit {
  [self sendEvent:AG_TOKEN_EXPIRED params:nil];
}

#pragma mark - AgoraRtmChannelDelegate

- (void)channel:(AgoraRtmChannel *_Nonnull)channel memberJoined:(AgoraRtmMember *_Nonnull)member {
  [self sendEvent:AG_CHANNELMEMBERJOINED params:@{
                                                  @"channelId": member.channelId,
                                                  @"uid": member.userId
                                                  }];
}

- (void)channel:(AgoraRtmChannel *_Nonnull)channel memberLeft:(AgoraRtmMember *_Nonnull)member {
  [self sendEvent:AG_CHANNELMEMBERLEFT params:@{
                                                @"channelId": member.channelId,
                                                @"uid": member.userId
                                                }];
}

- (void)channel:(AgoraRtmChannel *_Nonnull)channel messageReceived:(AgoraRtmMessage *_Nonnull)message fromMember:(AgoraRtmMember *_Nonnull)member {
  [self sendEvent:AG_CHANNELMESSAGERECEVIED params:@{
                                                     @"channelId": member.channelId,
                                                     @"uid": member.userId,
                                                     @"text": message.text,
                                                     @"ts": @(message.serverReceivedTs),
                                                     @"offline": @(message.isOfflineMessage)
                                                     }];
}

#pragma mark - AgoraRtmCallDelegate

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit localInvitationReceivedByPeer:(AgoraRtmLocalInvitation *_Nonnull)localInvitation {
  [_localInvitations setObject:localInvitation forKey:localInvitation.calleeId];
  [self sendEvent:AG_LOCALINVITATIONRECEIVEDBYPEER params:@{
                                                            @"calleeId": localInvitation.calleeId,
                                                            @"content":localInvitation.content,
                                                            @"state": @(localInvitation.state),
                                                            @"channelId": localInvitation.channelId,
                                                            @"response": localInvitation.response
                                                            }];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit localInvitationAccepted:(AgoraRtmLocalInvitation *_Nonnull)localInvitation withResponse:(NSString *_Nullable)response {
  [self sendEvent:AG_LOCALINVITATIONACCEPTED params:@{
                                                      @"calleeId": localInvitation.calleeId,
                                                      @"content":localInvitation.content,
                                                      @"state": @(localInvitation.state),
                                                      @"channelId": localInvitation.channelId,
                                                      @"response": localInvitation.response
                                                      }];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit localInvitationRefused:(AgoraRtmLocalInvitation *_Nonnull)localInvitation withResponse:(NSString *_Nullable)response {
  [self sendEvent:AG_LOCALINVITATIONREFUSED params:@{
                                                     @"calleeId": localInvitation.calleeId,
                                                     @"content":localInvitation.content,
                                                     @"state": @(localInvitation.state),
                                                     @"channelId": localInvitation.channelId,
                                                     @"response": localInvitation.response
                                                     }];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit localInvitationCanceled:(AgoraRtmLocalInvitation *_Nonnull)localInvitation {
  [self sendEvent:AG_LOCALINVITATIONCANCELED params:@{
                                                      @"calleeId": localInvitation.calleeId,
                                                      @"content":localInvitation.content,
                                                      @"state": @(localInvitation.state),
                                                      @"channelId": localInvitation.channelId,
                                                      @"response": localInvitation.response
                                                      }];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit localInvitationFailure:(AgoraRtmLocalInvitation *_Nonnull)localInvitation errorCode:(AgoraRtmLocalInvitationErrorCode)errorCode {
  [self sendEvent:AG_LOCALINVITATIONFAILURE params:@{
                                                     @"calleeId": localInvitation.calleeId,
                                                     @"content": localInvitation.content,
                                                     @"state": @(localInvitation.state),
                                                     @"channelId": localInvitation.channelId,
                                                     @"response": localInvitation.response,
                                                     @"code": @(errorCode)
                                                     }];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit remoteInvitationReceived:(AgoraRtmRemoteInvitation *_Nonnull)remoteInvitation {
  [_remoteInvitations setObject:remoteInvitation forKey:remoteInvitation.callerId];
  [self sendEvent:AG_REMOTEINVITATIONRECEIVED params:@{
                                                       @"callerId": remoteInvitation.callerId,
                                                       @"content": remoteInvitation.content,
                                                       @"state": @(remoteInvitation.state),
                                                       @"channelId": remoteInvitation.channelId,
                                                       @"response": remoteInvitation.response
                                                       }];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit remoteInvitationRefused:(AgoraRtmRemoteInvitation *_Nonnull)remoteInvitation {
  [self sendEvent:AG_REMOTEINVITATIONREFUSED params:@{
                                                      @"callerId": remoteInvitation.callerId,
                                                      @"content": remoteInvitation.content,
                                                      @"state": @(remoteInvitation.state),
                                                      @"channelId": remoteInvitation.channelId,
                                                      @"response": remoteInvitation.response
                                                      }];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit remoteInvitationAccepted:(AgoraRtmRemoteInvitation *_Nonnull)remoteInvitation {
  [self sendEvent:AG_REMOTEINVITATIONACCEPTED params:@{
                                                       @"callerId": remoteInvitation.callerId,
                                                       @"content": remoteInvitation.content,
                                                       @"state": @(remoteInvitation.state),
                                                       @"channelId": remoteInvitation.channelId,
                                                       @"response": remoteInvitation.response
                                                       }];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit remoteInvitationCanceled:(AgoraRtmRemoteInvitation *_Nonnull)remoteInvitation {
  [self sendEvent:AG_REMOTEINVITATIONCANCELED params:@{
                                                       @"callerId": remoteInvitation.callerId,
                                                       @"content": remoteInvitation.content,
                                                       @"state": @(remoteInvitation.state),
                                                       @"channelId": remoteInvitation.channelId,
                                                       @"response": remoteInvitation.response
                                                       }];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit remoteInvitationFailure:(AgoraRtmRemoteInvitation *_Nonnull)remoteInvitation errorCode:(AgoraRtmRemoteInvitationErrorCode)errorCode {
  [self sendEvent:AG_REMOTEINVITATIONFAILURE params:@{
                                                      @"callerId": remoteInvitation.callerId,
                                                      @"content": remoteInvitation.content,
                                                      @"state": @(remoteInvitation.state),
                                                      @"channelId": remoteInvitation.channelId,
                                                      @"response": remoteInvitation.response,
                                                      @"code": @(errorCode)
                                                      }];
}


@end
