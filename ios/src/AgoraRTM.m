//
//  AgoraRTM.m
//  AgoraRTM
//
//  Created by Matrixbirds on 2019/5/27.
//

#import "AgoraRTM.h"
#import "AgoraConst.h"

@interface AgoraRTM ()
@property(strong, nonatomic) AgoraRtmKit *rtmKit;
@property(strong, nonatomic) AgoraRtmCallKit *rtmCallKit;
@property(strong, nonatomic) NSMutableDictionary<NSString *, AgoraRtmChannel *> *channels;
@property(strong, nonatomic) NSMutableDictionary<NSString *, AgoraRtmLocalInvitation *> *localInvitations;
@property(strong, nonatomic) NSMutableDictionary<NSString *, AgoraRtmRemoteInvitation *> *remoteInvitations;
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

- (void)sendEvent:(NSString *)msg params:(NSDictionary *)params {
    if (hasListeners) {
        [self sendEventWithName:msg body:params];
    }
}

- (NSArray<NSString *> *)supportedEvents {
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
RCT_EXPORT_METHOD(init:
    (NSString *) appId
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    self.rtmKit = [[AgoraRtmKit new] initWithAppId:appId delegate:self];
    self.rtmCallKit = [[self rtmKit] getRtmCallKit];
    self.rtmCallKit.callDelegate = self;
    [self startObserving];
    resolve(nil);
}

// destroy AgoraRTM instance, remove event observing and it's internal resources
RCT_EXPORT_METHOD(destroy:
    (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    [self stopObserving];
    [self.localInvitations removeAllObjects];
    [self.remoteInvitations removeAllObjects];
    for (NSString *key in self.channels) {
        [self.rtmKit destroyChannelWithId:key];
    }
    [self.channels removeAllObjects];
    self.rtmCallKit = nil;
    self.rtmKit = nil;
    resolve(nil);
}

// get sdk version
RCT_EXPORT_METHOD(getSdkVersion:
    (RCTResponseSenderBlock) callback) {
    callback(@[[AgoraRtmKit getSDKVersion]]);
}

// set sdk log
RCT_EXPORT_METHOD(setSdkLog:
    (NSString *) path
            level:
            (NSInteger) level
            size:
            (NSInteger) size
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    int setpath = [self.rtmKit setLogFile:path];
    int setlevel = [self.rtmKit setLogFilters:(AgoraRtmLogFilter) level];
    int setsize = [self.rtmKit setLogFileSize:(int) size];

    resolve(@{
            @"path": @(setpath == 0),
            @"size": @(setsize == 0),
            @"level": @(setlevel == 0)
    });
}

// login
RCT_EXPORT_METHOD(login:
    (NSDictionary *) params
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    NSString *token = params[@"token"];
    NSString *uid = params[@"uid"];

    [[self rtmKit] loginByToken:token user:uid completion:^(AgoraRtmLoginErrorCode errorCode) {
        if (errorCode == AgoraRtmLoginErrorOk) {
            resolve(nil);
        } else {
            reject(@(errorCode).stringValue, @"", nil);
        }
    }];
}

// logout
RCT_EXPORT_METHOD(logout:
    (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    [[self rtmKit] logoutWithCompletion:^(AgoraRtmLogoutErrorCode errorCode) {
        if (errorCode == AgoraRtmLogoutErrorOk) {
            resolve(nil);
        } else {
            reject(@(errorCode).stringValue, @"", nil);
        }
    }];
}

// renewToken
RCT_EXPORT_METHOD(renewToken:
    (NSString *) token
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    [[self rtmKit] renewToken:token completion:^(NSString *token, AgoraRtmRenewTokenErrorCode errorCode) {
        if (errorCode == AgoraRtmRenewTokenErrorOk) {
            resolve(nil);
        } else {
            reject(@(errorCode).stringValue, @"", nil);
        }
    }];
}

// sendMessageToPeer
RCT_EXPORT_METHOD(sendMessageToPeer:
    (NSDictionary *) params
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    BOOL offline = [params[@"offline"] boolValue];
    NSString *text = params[@"text"];
    NSString *peerId = params[@"peerId"];

    AgoraRtmSendMessageOptions *options = [AgoraRtmSendMessageOptions new];
    [options setEnableOfflineMessaging:offline];
    AgoraRtmMessage *message = [[AgoraRtmMessage new] initWithText:text];
    [[self rtmKit] sendMessage:message toPeer:peerId sendMessageOptions:options completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
        if (errorCode == AgoraRtmSendPeerMessageErrorOk) {
            resolve(nil);
        } else {
            reject(@(errorCode).stringValue, @"", nil);
        }
    }];
}

// join channel
RCT_EXPORT_METHOD(joinChannel:
    (NSString *) channelId
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    AgoraRtmChannel *rtmChannel = [self.rtmKit createChannelWithId:channelId delegate:self];
    if (rtmChannel == nil) {
        reject(@"-1", @"channel_create_failed", nil);
    } else {
        [rtmChannel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
            if (errorCode == AgoraRtmJoinChannelErrorOk) {
                resolve(nil);
            } else {
                reject(@(errorCode).stringValue, @"", nil);
            }
        }];
        self.channels[channelId] = rtmChannel;
    }
}

// leave channel
RCT_EXPORT_METHOD(leaveChannel:
    (NSString *) channelId
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    AgoraRtmChannel *rtmChannel = self.channels[channelId];
    if (rtmChannel == nil) {
        reject(@"-1", @"channel_not_found", nil);
    } else {
        __weak typeof(self) weakSelf = self;
        [rtmChannel leaveWithCompletion:^(AgoraRtmLeaveChannelErrorCode errorCode) {
            if (errorCode == AgoraRtmLeaveChannelErrorOk) {
                [weakSelf.rtmKit destroyChannelWithId:channelId];
                [weakSelf.channels removeObjectForKey:channelId];
                resolve(nil);
            } else {
                reject(@(errorCode).stringValue, @"", nil);
            }
        }];
    }
}

// get channel members by channelId
RCT_EXPORT_METHOD(getChannelMembersBychannelId:
    (NSString *) channelId
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    AgoraRtmChannel *rtmChannel = self.channels[channelId];
    if (rtmChannel == nil) {
        reject(@"-1", @"channel_not_found", nil);
    } else {
        [rtmChannel getMembersWithCompletion:^(NSArray<AgoraRtmMember *> *_Nullable members, AgoraRtmGetMembersErrorCode errorCode) {
            if (errorCode == AgoraRtmGetMembersErrorOk) {
                NSMutableArray<NSDictionary *> *exportMembers = [NSMutableArray new];
                for (AgoraRtmMember *member in members) {
                    [exportMembers addObject:@{
                            @"uid": member.userId,
                            @"channelId": member.channelId
                    }];
                }
                resolve(@{@"members": exportMembers});
            } else {
                reject(@(errorCode).stringValue, @"", nil);
            }
        }];
    }
}

// send channel message by channel id
RCT_EXPORT_METHOD(sendMessageByChannelId:
    (NSDictionary *) params
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    NSString *channelId = params[@"channelId"];
    NSString *text = params[@"text"];

    AgoraRtmChannel *rtmChannel = self.channels[channelId];
    if (rtmChannel == nil) {
        reject(@"-1", @"channel_not_found", nil);
    } else {
        AgoraRtmMessage *message = [[AgoraRtmMessage new] initWithText:text];
        [rtmChannel sendMessage:message completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
            if (errorCode == AgoraRtmSendChannelMessageErrorOk) {
                resolve(nil);
            } else {
                reject(@(errorCode).stringValue, @"", nil);
            }
        }];
    }
}

// query peer online status with ids
RCT_EXPORT_METHOD(queryPeersOnlineStatus:
    (NSDictionary *) params
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    NSArray *ids = params[@"ids"];

    [[self rtmKit] queryPeersOnlineStatus:ids completion:^(NSArray<AgoraRtmPeerOnlineStatus *> *peerOnlineStatus, AgoraRtmQueryPeersOnlineErrorCode errorCode) {
        if (errorCode == AgoraRtmQueryPeersOnlineErrorOk) {
            NSMutableArray<NSDictionary *> *items = [NSMutableArray new];
            for (AgoraRtmPeerOnlineStatus *item in peerOnlineStatus) {
                [items addObject:@{
                        @"online": @(item.isOnline),
                        @"uid": item.peerId,
                }];
            }
            resolve(@{@"items": items});
        } else {
            reject(@(errorCode).stringValue, @"", nil);
        }
    }];
}

// setup local user attributes
RCT_EXPORT_METHOD(setLocalUserAttributes:
    (NSDictionary *) params
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    NSMutableArray<AgoraRtmAttribute *> *attributes = [[NSMutableArray<AgoraRtmAttribute *> alloc] init];
    for (NSDictionary *attribute in params[@"attributes"]) {
        AgoraRtmAttribute *rtmAttribute = [[AgoraRtmAttribute alloc] init];
        rtmAttribute.key = attribute[@"key"];
        rtmAttribute.value = attribute[@"value"];
        [attributes addObject:rtmAttribute];
    }

    [self.rtmKit setLocalUserAttributes:attributes completion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
        if (errorCode == AgoraRtmAttributeOperationErrorOk) {
            resolve(nil);
        } else {
            reject(@(errorCode).stringValue, @"", nil);
        }
    }];
}

// replace local user attributes
RCT_EXPORT_METHOD(replaceLocalUserAttributes:
    (NSDictionary *) params
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    NSMutableArray<AgoraRtmAttribute *> *attributes = [[NSMutableArray<AgoraRtmAttribute *> alloc] init];
    for (NSDictionary *attribute in params[@"attributes"]) {
        AgoraRtmAttribute *rtmAttribute = [[AgoraRtmAttribute alloc] init];
        rtmAttribute.key = attribute[@"key"];
        rtmAttribute.value = attribute[@"value"];
        [attributes addObject:rtmAttribute];
    }

    [self.rtmKit addOrUpdateLocalUserAttributes:attributes completion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
        if (errorCode == AgoraRtmAttributeOperationErrorOk) {
            resolve(nil);
        } else {
            reject(@(errorCode).stringValue, @"", nil);
        }
    }];
}

// remove local user attributes by keys
RCT_EXPORT_METHOD(removeLocalUserAttributesByKeys:
    (NSDictionary *) params
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    NSArray<NSString *> *keys = params[@"keys"];

    [self.rtmKit deleteLocalUserAttributesByKeys:keys completion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
        if (errorCode == AgoraRtmAttributeOperationErrorOk) {
            resolve(nil);
        } else {
            reject(@(errorCode).stringValue, @"", nil);
        }
    }];
}

// remove all local user attributes
RCT_EXPORT_METHOD(removeAllLocalUserAttributes:
    (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    [self.rtmKit clearLocalUserAttributesWithCompletion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
        if (errorCode == AgoraRtmAttributeOperationErrorOk) {
            resolve(nil);
        } else {
            reject(@(errorCode).stringValue, @"", nil);
        }
    }];
}

// get local user attributes by uid
RCT_EXPORT_METHOD(getUserAttributesByUid:
    (NSString *) uid
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    [self.rtmKit getUserAllAttributes:uid completion:^(NSArray<AgoraRtmAttribute *> *_Nullable attributes, NSString *userId, AgoraRtmProcessAttributeErrorCode errorCode) {
        if (errorCode == AgoraRtmAttributeOperationErrorOk) {
            NSMutableDictionary<NSString *, NSString *> *exportAttributes = [NSMutableDictionary dictionary];
            for (AgoraRtmAttribute *attribute in attributes) {
                exportAttributes[attribute.key] = attribute.value;
            }
            resolve(@{
                    @"uid": uid,
                    @"attributes": exportAttributes
            });
        } else {
            reject(@(errorCode).stringValue, @"", nil);
        }
    }];
}

// send local invitation
RCT_EXPORT_METHOD(sendLocalInvitation:
    (NSDictionary *) params
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    NSString *calleeId = params[@"uid"];
    NSString *content = params[@"content"];
    NSString *channelId = params[@"channelId"];

    AgoraRtmLocalInvitation *localInvitation = [[AgoraRtmLocalInvitation new] initWithCalleeId:calleeId];
    localInvitation.content = content;
    localInvitation.channelId = channelId;

    __weak typeof(self) weakSelf = self;
    [self.rtmCallKit sendLocalInvitation:localInvitation completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
        if (errorCode == AgoraRtmInvitationApiCallErrorOk) {
            weakSelf.localInvitations[calleeId] = localInvitation;
            resolve(nil);
        } else {
            reject(@(errorCode).stringValue, @"", nil);
        }
    }];
}

// cancel local invitation
RCT_EXPORT_METHOD(cancelLocalInvitation:
    (NSDictionary *) params
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    NSString *calleeId = params[@"uid"];

    AgoraRtmLocalInvitation *localInvitation = self.localInvitations[calleeId];
    if (localInvitation == nil) {
        reject(@"-1", @"local_invitation_not_found", nil);
    } else {
        __weak typeof(self) weakSelf = self;
        [self.rtmCallKit cancelLocalInvitation:localInvitation completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
            if (errorCode == AgoraRtmInvitationApiCallErrorOk) {
                [weakSelf.localInvitations removeObjectForKey:calleeId];
                resolve(nil);
            } else {
                reject(@(errorCode).stringValue, @"", nil);
            }
        }];
    }
}

// accept remote invitation
RCT_EXPORT_METHOD(acceptRemoteInvitation:
    (NSDictionary *) params
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    NSString *calleeId = params[@"uid"];
    NSString *response = params[@"response"];

    AgoraRtmRemoteInvitation *remoteInvitation = self.remoteInvitations[calleeId];
    if (remoteInvitation == nil) {
        reject(@"-1", @"remote_invitation_not_found", nil);
    } else {
        remoteInvitation.response = response;

        __weak typeof(self) weakSelf = self;
        [self.rtmCallKit acceptRemoteInvitation:remoteInvitation completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
            if (errorCode == AgoraRtmInvitationApiCallErrorOk) {
                [weakSelf.remoteInvitations removeObjectForKey:calleeId];
                resolve(nil);
            } else {
                reject(@(errorCode).stringValue, @"", nil);
            }
        }];
    }
}

// refuse remote invitation
RCT_EXPORT_METHOD(refuseRemoteInvitation:
    (NSDictionary *) params
            resolve:
            (RCTPromiseResolveBlock) resolve
            reject:
            (RCTPromiseRejectBlock) reject) {
    NSString *calleeId = params[@"uid"];
    NSString *response = params[@"response"];

    AgoraRtmRemoteInvitation *remoteInvitation = self.remoteInvitations[calleeId];
    if (remoteInvitation == nil) {
        reject(@"-1", @"remote_invitation_not_found", nil);
    } else {
        remoteInvitation.response = response;

        __weak typeof(self) weakSelf = self;
        [self.rtmCallKit refuseRemoteInvitation:remoteInvitation completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
            if (errorCode == AgoraRtmInvitationApiCallErrorOk) {
                [weakSelf.remoteInvitations removeObjectForKey:calleeId];
                resolve(nil);
            } else {
                reject(@(errorCode).stringValue, @"", nil);
            }
        }];
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

- (void)rtmKit:(AgoraRtmKit *)kit PeersOnlineStatusChanged:(NSArray<AgoraRtmPeerOnlineStatus *> *)onlineStatus {

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

- (void)channel:(AgoraRtmChannel *)channel attributeUpdate:(NSArray<AgoraRtmChannelAttribute *> *)attributes {

}

- (void)channel:(AgoraRtmChannel *)channel memberCount:(int)count {

}

#pragma mark - AgoraRtmCallDelegate

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit localInvitationReceivedByPeer:(AgoraRtmLocalInvitation *_Nonnull)localInvitation {
    [self sendEvent:AG_LOCALINVITATIONRECEIVEDBYPEER params:@{
            @"calleeId": localInvitation.calleeId,
            @"content": localInvitation.content,
            @"state": @(localInvitation.state),
            @"channelId": localInvitation.channelId,
            @"response": localInvitation.response
    }];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit localInvitationAccepted:(AgoraRtmLocalInvitation *_Nonnull)localInvitation withResponse:(NSString *_Nullable)response {
    [self sendEvent:AG_LOCALINVITATIONACCEPTED params:@{
            @"calleeId": localInvitation.calleeId,
            @"content": localInvitation.content,
            @"state": @(localInvitation.state),
            @"channelId": localInvitation.channelId,
            @"response": localInvitation.response
    }];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit localInvitationRefused:(AgoraRtmLocalInvitation *_Nonnull)localInvitation withResponse:(NSString *_Nullable)response {
    [self sendEvent:AG_LOCALINVITATIONREFUSED params:@{
            @"calleeId": localInvitation.calleeId,
            @"content": localInvitation.content,
            @"state": @(localInvitation.state),
            @"channelId": localInvitation.channelId,
            @"response": localInvitation.response
    }];
}

- (void)rtmCallKit:(AgoraRtmCallKit *_Nonnull)callKit localInvitationCanceled:(AgoraRtmLocalInvitation *_Nonnull)localInvitation {
    [self sendEvent:AG_LOCALINVITATIONCANCELED params:@{
            @"calleeId": localInvitation.calleeId,
            @"content": localInvitation.content,
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
    self.remoteInvitations[remoteInvitation.callerId] = remoteInvitation;

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
