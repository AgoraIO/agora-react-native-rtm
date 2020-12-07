//
//  AgoraRTM.m
//  AgoraRTM
//
//  Created by Matrixbirds on 2019/5/27.
//

#import "AgoraRTM.h"
#import "AgoraConst.h"
#import "Extensions.h"

@interface AgoraRTM ()
@property(strong, nonatomic) AgoraRtmKit *rtmKit;
@property(strong, nonatomic)
    NSMutableDictionary<NSString *, AgoraRtmChannel *> *channels;
@property(strong, nonatomic)
    NSMutableDictionary<NSNumber *, AgoraRtmLocalInvitation *>
        *localInvitations;
@property(strong, nonatomic)
    NSMutableDictionary<NSNumber *, AgoraRtmRemoteInvitation *>
        *remoteInvitations;
@end

@implementation AgoraRTM {
  BOOL hasListeners;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.channels = [NSMutableDictionary dictionary];
    self.localInvitations = [NSMutableDictionary dictionary];
    self.remoteInvitations = [NSMutableDictionary dictionary];
  }
  return self;
}

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

RCT_EXPORT_MODULE(AgoraRTM);

- (void)startObserving {
  hasListeners = YES;
}

- (void)stopObserving {
  hasListeners = NO;
}

- (void)sendEvent:(NSString *)msg params:(NSArray *)params {
  if (hasListeners) {
    [self sendEventWithName:msg body:params];
  }
}

- (NSDictionary *)constantsToExport {
  return @{@"prefix" : @"io.agora.rtm."};
}

- (NSArray<NSString *> *)supportedEvents {
  return @[
    ConnectionStateChanged, MessageReceived, LocalInvitationReceivedByPeer,
    LocalInvitationAccepted, LocalInvitationRefused, LocalInvitationCanceled,
    LocalInvitationFailure, RemoteInvitationFailure, RemoteInvitationReceived,
    RemoteInvitationAccepted, RemoteInvitationRefused, RemoteInvitationCanceled,
    ChannelMessageReceived, ChannelMemberJoined, ChannelMemberLeft,
    TokenExpired, PeersOnlineStatusChanged, ChannelAttributesUpdated,
    MemberCountUpdated
  ];
}

RCT_EXPORT_METHOD(destroy
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self stopObserving];
  [self.localInvitations removeAllObjects];
  [self.remoteInvitations removeAllObjects];
  for (NSString *key in self.channels) {
    [self.rtmKit destroyChannelWithId:key];
  }
  [self.channels removeAllObjects];
  self.rtmKit = nil;
  resolve(nil);
}

RCT_EXPORT_METHOD(login
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit loginByToken:params[@"token"]
                       user:params[@"userId"]
                 completion:^(AgoraRtmLoginErrorCode errorCode) {
                   if (errorCode == AgoraRtmLoginErrorOk) {
                     resolve(nil);
                   } else {
                     reject(@(errorCode).stringValue, @"", nil);
                   }
                 }];
}

RCT_EXPORT_METHOD(logout
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit logoutWithCompletion:^(AgoraRtmLogoutErrorCode errorCode) {
    if (errorCode == AgoraRtmLogoutErrorOk) {
      resolve(nil);
    } else {
      reject(@(errorCode).stringValue, @"", nil);
    }
  }];
}

RCT_EXPORT_METHOD(sendMessageToPeer
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit sendMessage:[Extensions mapToRtmMessage:params]
                    toPeer:params[@"peerId"]
        sendMessageOptions:[Extensions mapToSendMessageOptions:params]
                completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
                  if (errorCode == AgoraRtmSendPeerMessageErrorOk) {
                    resolve(nil);
                  } else {
                    reject(@(errorCode).stringValue, @"", nil);
                  }
                }];
}

RCT_EXPORT_METHOD(queryPeersOnlineStatus
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit
      queryPeersOnlineStatus:[Extensions mapToPeerIds:params]
                  completion:^(
                      NSArray<AgoraRtmPeerOnlineStatus *> *peerOnlineStatus,
                      AgoraRtmQueryPeersOnlineErrorCode errorCode) {
                    if (errorCode == AgoraRtmQueryPeersOnlineErrorOk) {
                      NSMutableDictionary *ret = [NSMutableDictionary new];
                      for (AgoraRtmPeerOnlineStatus *item in peerOnlineStatus) {
                        ret[item.peerId] = @(item.isOnline);
                      }
                      resolve(ret);
                    } else {
                      reject(@(errorCode).stringValue, @"", nil);
                    }
                  }];
}

RCT_EXPORT_METHOD(subscribePeersOnlineStatus
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit
      subscribePeersOnlineStatus:[Extensions mapToPeerIds:params]
                      completion:^(
                          AgoraRtmPeerSubscriptionStatusErrorCode errorCode) {
                        if (errorCode ==
                            AgoraRtmPeerSubscriptionStatusErrorOk) {
                          resolve(nil);
                        } else {
                          reject(@(errorCode).stringValue, @"", nil);
                        }
                      }];
}

RCT_EXPORT_METHOD(unsubscribePeersOnlineStatus
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit
      unsubscribePeersOnlineStatus:[Extensions mapToPeerIds:params]
                        completion:^(
                            AgoraRtmPeerSubscriptionStatusErrorCode errorCode) {
                          if (errorCode ==
                              AgoraRtmPeerSubscriptionStatusErrorOk) {
                            resolve(nil);
                          } else {
                            reject(@(errorCode).stringValue, @"", nil);
                          }
                        }];
}

RCT_EXPORT_METHOD(queryPeersBySubscriptionOption
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit
      queryPeersBySubscriptionOption:params[@"option"]
                          completion:^(
                              NSArray<NSString *> *peers,
                              AgoraRtmQueryPeersBySubscriptionOptionErrorCode
                                  errorCode) {
                            if (errorCode ==
                                AgoraRtmQueryPeersBySubscriptionOptionErrorOk) {
                              resolve(peers);
                            } else {
                              reject(@(errorCode).stringValue, @"", nil);
                            }
                          }];
}

RCT_EXPORT_METHOD(renewToken
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit
      renewToken:params[@"token"]
      completion:^(NSString *token, AgoraRtmRenewTokenErrorCode errorCode) {
        if (errorCode == AgoraRtmRenewTokenErrorOk) {
          resolve(nil);
        } else {
          reject(@(errorCode).stringValue, @"", nil);
        }
      }];
}

RCT_EXPORT_METHOD(setLocalUserAttributes
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit
      setLocalUserAttributes:[Extensions mapToUserAttributes:params]
                  completion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
                    if (errorCode == AgoraRtmAttributeOperationErrorOk) {
                      resolve(nil);
                    } else {
                      reject(@(errorCode).stringValue, @"", nil);
                    }
                  }];
}

RCT_EXPORT_METHOD(addOrUpdateLocalUserAttributes
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit
      addOrUpdateLocalUserAttributes:[Extensions mapToUserAttributes:params]
                          completion:^(
                              AgoraRtmProcessAttributeErrorCode errorCode) {
                            if (errorCode ==
                                AgoraRtmAttributeOperationErrorOk) {
                              resolve(nil);
                            } else {
                              reject(@(errorCode).stringValue, @"", nil);
                            }
                          }];
}

RCT_EXPORT_METHOD(deleteLocalUserAttributesByKeys
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit
      deleteLocalUserAttributesByKeys:[Extensions mapToAttributeKeys:params]
                           completion:^(
                               AgoraRtmProcessAttributeErrorCode errorCode) {
                             if (errorCode ==
                                 AgoraRtmAttributeOperationErrorOk) {
                               resolve(nil);
                             } else {
                               reject(@(errorCode).stringValue, @"", nil);
                             }
                           }];
}

RCT_EXPORT_METHOD(clearLocalUserAttributes
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit clearLocalUserAttributesWithCompletion:^(
                   AgoraRtmProcessAttributeErrorCode errorCode) {
    if (errorCode == AgoraRtmAttributeOperationErrorOk) {
      resolve(nil);
    } else {
      reject(@(errorCode).stringValue, @"", nil);
    }
  }];
}

RCT_EXPORT_METHOD(getUserAttributes
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit
      getUserAllAttributes:params[@"userId"]
                completion:^(NSArray<AgoraRtmAttribute *> *_Nullable attributes,
                             NSString *userId,
                             AgoraRtmProcessAttributeErrorCode errorCode) {
                  if (errorCode == AgoraRtmAttributeOperationErrorOk) {
                    NSMutableArray *ret = [NSMutableArray new];
                    for (AgoraRtmAttribute *item in attributes) {
                      [ret addObject:[Extensions rtmAttributeToMap:item]];
                    }
                    resolve(ret);
                  } else {
                    reject(@(errorCode).stringValue, @"", nil);
                  }
                }];
}

RCT_EXPORT_METHOD(getUserAttributesByKeys
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit
      getUserAttributes:params[@"userId"]
                 ByKeys:[Extensions mapToAttributeKeys:params]
             completion:^(NSArray<AgoraRtmAttribute *> *_Nullable attributes,
                          NSString *userId,
                          AgoraRtmProcessAttributeErrorCode errorCode) {
               if (errorCode == AgoraRtmAttributeOperationErrorOk) {
                 NSMutableArray *ret = [NSMutableArray new];
                 for (AgoraRtmAttribute *item in attributes) {
                   [ret addObject:[Extensions rtmAttributeToMap:item]];
                 }
                 resolve(ret);
               } else {
                 reject(@(errorCode).stringValue, @"", nil);
               }
             }];
}

RCT_EXPORT_METHOD(setChannelAttributes
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit setChannel:params[@"channelId"]
               Attributes:[Extensions mapToChannelAttributes:params]
                  Options:[Extensions mapToChannelAttributeOptions:params]
               completion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
                 if (errorCode == AgoraRtmAttributeOperationErrorOk) {
                   resolve(nil);
                 } else {
                   reject(@(errorCode).stringValue, @"", nil);
                 }
               }];
}

RCT_EXPORT_METHOD(addOrUpdateChannelAttributes
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit
      addOrUpdateChannel:params[@"channelId"]
              Attributes:[Extensions mapToChannelAttributes:params]
                 Options:[Extensions mapToChannelAttributeOptions:params]
              completion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
                if (errorCode == AgoraRtmAttributeOperationErrorOk) {
                  resolve(nil);
                } else {
                  reject(@(errorCode).stringValue, @"", nil);
                }
              }];
}

RCT_EXPORT_METHOD(deleteChannelAttributesByKeys
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit deleteChannel:params[@"channelId"]
            AttributesByKeys:[Extensions mapToAttributeKeys:params]
                     Options:[Extensions mapToChannelAttributeOptions:params]
                  completion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
                    if (errorCode == AgoraRtmAttributeOperationErrorOk) {
                      resolve(nil);
                    } else {
                      reject(@(errorCode).stringValue, @"", nil);
                    }
                  }];
}

RCT_EXPORT_METHOD(clearChannelAttributes
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit clearChannel:params[@"channelId"]
                       Options:[Extensions mapToChannelAttributeOptions:params]
      AttributesWithCompletion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
        if (errorCode == AgoraRtmAttributeOperationErrorOk) {
          resolve(nil);
        } else {
          reject(@(errorCode).stringValue, @"", nil);
        }
      }];
}

RCT_EXPORT_METHOD(getChannelAttributes
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit
      getChannelAllAttributes:params[@"channelId"]
                   completion:^(NSArray<AgoraRtmChannelAttribute *>
                                    *_Nullable attributes,
                                AgoraRtmProcessAttributeErrorCode errorCode) {
                     if (errorCode == AgoraRtmAttributeOperationErrorOk) {
                       NSMutableArray *ret = [NSMutableArray new];
                       for (AgoraRtmChannelAttribute *item in attributes) {
                         [ret addObject:[Extensions
                                            rtmChannelAttributeToMap:item]];
                       }
                       resolve(ret);
                     } else {
                       reject(@(errorCode).stringValue, @"", nil);
                     }
                   }];
}

RCT_EXPORT_METHOD(getChannelAttributesByKeys
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit
      getChannelAttributes:params[@"channelId"]
                    ByKeys:[Extensions mapToAttributeKeys:params]
                completion:^(
                    NSArray<AgoraRtmChannelAttribute *> *_Nullable attributes,
                    AgoraRtmProcessAttributeErrorCode errorCode) {
                  if (errorCode == AgoraRtmAttributeOperationErrorOk) {
                    NSMutableArray *ret = [NSMutableArray new];
                    for (AgoraRtmChannelAttribute *item in attributes) {
                      [ret
                          addObject:[Extensions rtmChannelAttributeToMap:item]];
                    }
                    resolve(ret);
                  } else {
                    reject(@(errorCode).stringValue, @"", nil);
                  }
                }];
}

RCT_EXPORT_METHOD(setParameters
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  int res = [self.rtmKit setParameters:params[@"parameters"]];
  if (res == 0) {
    resolve(nil);
  } else {
    reject(@(res).stringValue, @"", nil);
  }
}

RCT_EXPORT_METHOD(setLogFile
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  int res = [self.rtmKit setLogFile:params[@"filePath"]];
  if (res == 0) {
    resolve(nil);
  } else {
    reject(@(res).stringValue, @"", nil);
  }
}

RCT_EXPORT_METHOD(setLogFilter
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  int res = [self.rtmKit setLogFilters:params[@"filter"]];
  if (res == 0) {
    resolve(nil);
  } else {
    reject(@(res).stringValue, @"", nil);
  }
}

RCT_EXPORT_METHOD(setLogFileSize
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  int res = [self.rtmKit setLogFileSize:params[@"fileSizeInKBytes"]];
  if (res == 0) {
    resolve(nil);
  } else {
    reject(@(res).stringValue, @"", nil);
  }
}

RCT_EXPORT_METHOD(createInstance
                  : (NSString *)appId resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  self.rtmKit = [[AgoraRtmKit new] initWithAppId:appId delegate:self];
  [self.rtmKit getRtmCallKit].callDelegate = self;
  [self startObserving];
  resolve(nil);
}

// get sdk version
RCT_EXPORT_METHOD(getSdkVersion
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  resolve([AgoraRtmKit getSDKVersion]);
}

RCT_EXPORT_METHOD(joinChannel
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  AgoraRtmChannel *rtmChannel = [self getRtmChannel:params
                                             reject:reject
                                               init:YES];
  if (rtmChannel == nil)
    return;
  self.channels[params[@"channelId"]] = rtmChannel;
  [rtmChannel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
    if (errorCode == AgoraRtmJoinChannelErrorOk) {
      resolve(nil);
    } else {
      reject(@(errorCode).stringValue, @"", nil);
    }
  }];
}

RCT_EXPORT_METHOD(leaveChannel
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  AgoraRtmChannel *rtmChannel = [self getRtmChannel:params
                                             reject:reject
                                               init:NO];
  if (rtmChannel == nil)
    return;
  [rtmChannel leaveWithCompletion:^(AgoraRtmLeaveChannelErrorCode errorCode) {
    if (errorCode == AgoraRtmLeaveChannelErrorOk) {
      resolve(nil);
    } else {
      reject(@(errorCode).stringValue, @"", nil);
    }
  }];
}

RCT_EXPORT_METHOD(sendMessage
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  AgoraRtmChannel *rtmChannel = [self getRtmChannel:params
                                             reject:reject
                                               init:NO];
  if (rtmChannel == nil)
    return;
  [rtmChannel sendMessage:[Extensions mapToRtmMessage:params]
       sendMessageOptions:[Extensions mapToSendMessageOptions:params]
               completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
                 if (errorCode == AgoraRtmSendChannelMessageErrorOk) {
                   resolve(nil);
                 } else {
                   reject(@(errorCode).stringValue, @"", nil);
                 }
               }];
}

RCT_EXPORT_METHOD(getMembers
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  AgoraRtmChannel *rtmChannel = [self getRtmChannel:params
                                             reject:reject
                                               init:NO];
  if (rtmChannel == nil)
    return;
  [rtmChannel
      getMembersWithCompletion:^(NSArray<AgoraRtmMember *> *_Nullable members,
                                 AgoraRtmGetMembersErrorCode errorCode) {
        if (errorCode == AgoraRtmGetMembersErrorOk) {
          NSMutableArray *ret = [NSMutableArray new];
          for (AgoraRtmMember *item in members) {
            [ret addObject:[Extensions rtmMemberToMap:item]];
          }
          resolve(ret);
        } else {
          reject(@(errorCode).stringValue, @"", nil);
        }
      }];
}

RCT_EXPORT_METHOD(releaseChannel
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  AgoraRtmChannel *rtmChannel = [self getRtmChannel:params
                                             reject:reject
                                               init:NO];
  if (rtmChannel == nil)
    return;
  [self.channels removeObjectForKey:params[@"channelId"]];
  resolve(nil);
}

- (AgoraRtmChannel *)getRtmChannel:(NSDictionary *)params
                            reject:(RCTPromiseRejectBlock)reject
                              init:(BOOL)init {
  NSString *channelId = params[@"channelId"];
  AgoraRtmChannel *rtmChannel = [self.channels objectForKey:channelId];
  if (rtmChannel == nil) {
    if (init) {
      return [self.rtmKit createChannelWithId:channelId delegate:self];
    }
    reject(@"101", @"", nil);
  }
  return rtmChannel;
}

- (AgoraRtmLocalInvitation *)getLocalInvitation:(NSDictionary *)params {
  AgoraRtmLocalInvitation *ret = nil;
  NSDictionary *localInvitation = params[@"localInvitation"];
  NSNumber *hash = localInvitation[@"hash"];
  if (hash.intValue == 0) {
    for (NSNumber *key in self.localInvitations) {
      if ([self.localInvitations[key].calleeId
              isEqualToString:localInvitation[@"calleeId"]]) {
        ret = self.localInvitations[key];
        break;
      }
    }
  } else {
    ret = self.localInvitations[hash];
  }
  NSString *content = localInvitation[@"content"];
  if (content) {
    ret.content = content;
  }
  NSString *channelId = localInvitation[@"channelId"];
  if (channelId) {
    ret.channelId = channelId;
  }
  return ret;
}

- (AgoraRtmRemoteInvitation *)getRemoteInvitation:(NSDictionary *)params {
  AgoraRtmRemoteInvitation *ret = nil;
  NSDictionary *remoteInvitation = params[@"remoteInvitation"];
  NSNumber *hash = remoteInvitation[@"hash"];
  if (hash == nil) {
    for (NSNumber *key in self.remoteInvitations) {
      if ([self.remoteInvitations[key].callerId
              isEqualToString:remoteInvitation[@"callerId"]]) {
        ret = self.remoteInvitations[key];
        break;
      }
    }
  } else {
    ret = self.remoteInvitations[hash];
  }
  NSString *response = remoteInvitation[@"response"];
  if (response) {
    ret.response = response;
  }
  return ret;
}

RCT_EXPORT_METHOD(createLocalInvitation
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  AgoraRtmLocalInvitation *localInvitation =
      [Extensions mapToLocalInvitation:params];
  self.localInvitations[@(localInvitation.hash)] = localInvitation;
  resolve([Extensions localInvitationToMap:localInvitation]);
}

RCT_EXPORT_METHOD(sendLocalInvitation
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit.rtmCallKit
      sendLocalInvitation:[self getLocalInvitation:params]
               completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
                 if (errorCode == AgoraRtmInvitationApiCallErrorOk) {
                   resolve(nil);
                 } else {
                   reject(@(errorCode).stringValue, @"", nil);
                 }
               }];
}

RCT_EXPORT_METHOD(cancelLocalInvitation
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit.rtmCallKit
      cancelLocalInvitation:[self getLocalInvitation:params]
                 completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
                   if (errorCode == AgoraRtmInvitationApiCallErrorOk) {
                     resolve(nil);
                   } else {
                     reject(@(errorCode).stringValue, @"", nil);
                   }
                 }];
}

RCT_EXPORT_METHOD(acceptRemoteInvitation
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit.rtmCallKit
      acceptRemoteInvitation:[self getRemoteInvitation:params]
                  completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
                    if (errorCode == AgoraRtmInvitationApiCallErrorOk) {
                      resolve(nil);
                    } else {
                      reject(@(errorCode).stringValue, @"", nil);
                    }
                  }];
}

RCT_EXPORT_METHOD(refuseRemoteInvitation
                  : (NSDictionary *)params resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject) {
  [self.rtmKit.rtmCallKit
      refuseRemoteInvitation:[self getRemoteInvitation:params]
                  completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
                    if (errorCode == AgoraRtmInvitationApiCallErrorOk) {
                      resolve(nil);
                    } else {
                      reject(@(errorCode).stringValue, @"", nil);
                    }
                  }];
}

#pragma mark - AgoraRtmDelegate

- (void)rtmKit:(AgoraRtmKit *_Nonnull)kit
    connectionStateChanged:(AgoraRtmConnectionState)state
                    reason:(AgoraRtmConnectionChangeReason)reason {
  [self sendEvent:ConnectionStateChanged params:@[ @(state), @(reason) ]];
}

- (void)rtmKit:(AgoraRtmKit *_Nonnull)kit
    messageReceived:(AgoraRtmMessage *_Nonnull)message
           fromPeer:(NSString *_Nonnull)peerId {
  [self sendEvent:MessageReceived
           params:@[ [Extensions rtmMessageToMap:message], peerId ]];
}

- (void)rtmKitTokenDidExpire:(AgoraRtmKit *_Nonnull)kit {
  [self sendEvent:TokenExpired params:nil];
}

- (void)rtmKit:(AgoraRtmKit *)kit
    PeersOnlineStatusChanged:
        (NSArray<AgoraRtmPeerOnlineStatus *> *)onlineStatus {
  NSMutableDictionary *ret = [NSMutableDictionary new];
  for (AgoraRtmPeerOnlineStatus *item in onlineStatus) {
    ret[item.peerId] = @(item.state);
  }
  [self sendEvent:PeersOnlineStatusChanged params:@[ ret ]];
}

#pragma mark - AgoraRtmChannelDelegate

- (void)channel:(AgoraRtmChannel *_Nonnull)channel
    memberJoined:(AgoraRtmMember *_Nonnull)member {
  [self sendEvent:ChannelMemberJoined
           params:@[ [Extensions rtmMemberToMap:member] ]];
}

- (void)channel:(AgoraRtmChannel *_Nonnull)channel
     memberLeft:(AgoraRtmMember *_Nonnull)member {
  [self sendEvent:ChannelMemberLeft
           params:@[ [Extensions rtmMemberToMap:member] ]];
}

- (void)channel:(AgoraRtmChannel *_Nonnull)channel
    messageReceived:(AgoraRtmMessage *_Nonnull)message
         fromMember:(AgoraRtmMember *_Nonnull)member {
  [self sendEvent:ChannelMessageReceived
           params:@[
             [Extensions rtmMessageToMap:message],
             [Extensions rtmMemberToMap:member]
           ]];
}

- (void)channel:(AgoraRtmChannel *)channel
    attributeUpdate:(NSArray<AgoraRtmChannelAttribute *> *)attributes {
  NSMutableArray *ret = [NSMutableArray new];
  for (AgoraRtmChannelAttribute *item in attributes) {
    [ret addObject:[Extensions rtmChannelAttributeToMap:item]];
  }
  [self sendEvent:ChannelAttributesUpdated params:@[ ret ]];
}

- (void)channel:(AgoraRtmChannel *)channel memberCount:(int)count {
  [self sendEvent:MemberCountUpdated params:@[ @(count) ]];
}

#pragma mark - AgoraRtmCallDelegate

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit
    localInvitationReceivedByPeer:
        (AgoraRtmLocalInvitation *_Nonnull)localInvitation {
  [self sendEvent:LocalInvitationReceivedByPeer
           params:@[ [Extensions localInvitationToMap:localInvitation] ]];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit
    localInvitationAccepted:(AgoraRtmLocalInvitation *_Nonnull)localInvitation
               withResponse:(NSString *_Nullable)response {
  [self.localInvitations removeObjectForKey:@(localInvitation.hash)];
  [self sendEvent:LocalInvitationAccepted
           params:@[
             [Extensions localInvitationToMap:localInvitation], response
           ]];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit
    localInvitationRefused:(AgoraRtmLocalInvitation *_Nonnull)localInvitation
              withResponse:(NSString *_Nullable)response {
  [self.localInvitations removeObjectForKey:@(localInvitation.hash)];
  [self sendEvent:LocalInvitationRefused
           params:@[
             [Extensions localInvitationToMap:localInvitation], response
           ]];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit
    localInvitationCanceled:(AgoraRtmLocalInvitation *_Nonnull)localInvitation {
  [self.localInvitations removeObjectForKey:@(localInvitation.hash)];
  [self sendEvent:LocalInvitationCanceled
           params:@[ [Extensions localInvitationToMap:localInvitation] ]];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit
    localInvitationFailure:(AgoraRtmLocalInvitation *_Nonnull)localInvitation
                 errorCode:(AgoraRtmLocalInvitationErrorCode)errorCode {
  [self.localInvitations removeObjectForKey:@(localInvitation.hash)];
  [self sendEvent:LocalInvitationFailure
           params:@[
             [Extensions localInvitationToMap:localInvitation], @(errorCode)
           ]];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit
    remoteInvitationReceived:
        (AgoraRtmRemoteInvitation *_Nonnull)remoteInvitation {
  self.remoteInvitations[remoteInvitation.callerId] = remoteInvitation;
  [self sendEvent:RemoteInvitationReceived
           params:@[ [Extensions remoteInvitationToMap:remoteInvitation] ]];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit
    remoteInvitationRefused:
        (AgoraRtmRemoteInvitation *_Nonnull)remoteInvitation {
  [self.remoteInvitations removeObjectForKey:@(remoteInvitation.hash)];
  [self sendEvent:RemoteInvitationRefused
           params:@[ [Extensions remoteInvitationToMap:remoteInvitation] ]];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit
    remoteInvitationAccepted:
        (AgoraRtmRemoteInvitation *_Nonnull)remoteInvitation {
  [self.remoteInvitations removeObjectForKey:@(remoteInvitation.hash)];
  [self sendEvent:RemoteInvitationAccepted
           params:@[ [Extensions remoteInvitationToMap:remoteInvitation] ]];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit
    remoteInvitationCanceled:
        (AgoraRtmRemoteInvitation *_Nonnull)remoteInvitation {
  [self.remoteInvitations removeObjectForKey:@(remoteInvitation.hash)];
  [self sendEvent:RemoteInvitationCanceled
           params:@[ [Extensions remoteInvitationToMap:remoteInvitation] ]];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit
    remoteInvitationFailure:(AgoraRtmRemoteInvitation *_Nonnull)remoteInvitation
                  errorCode:(AgoraRtmRemoteInvitationErrorCode)errorCode {
  [self.remoteInvitations removeObjectForKey:@(remoteInvitation.hash)];
  [self sendEvent:RemoteInvitationFailure
           params:@[
             [Extensions remoteInvitationToMap:remoteInvitation], @(errorCode)
           ]];
}

@end
