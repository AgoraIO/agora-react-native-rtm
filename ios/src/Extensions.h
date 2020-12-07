//
//  Extensions.h
//  AgoraRTM
//
//  Created by LXH on 2020/12/6.
//

#import <Foundation/Foundation.h>

#import <AgoraRtmKit/AgoraRtmKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Extensions : NSObject

+ (AgoraRtmMessage *)mapToRtmMessage:(NSDictionary *)map;

+ (AgoraRtmSendMessageOptions *)mapToSendMessageOptions:(NSDictionary *)map;

+ (NSArray<NSString *> *)mapToPeerIds:(NSDictionary *)map;

+ (NSArray<AgoraRtmAttribute *> *)mapToUserAttributes:(NSDictionary *)map;

+ (NSArray<NSString *> *)mapToAttributeKeys:(NSDictionary *)map;

+ (NSArray<AgoraRtmChannelAttribute *> *)mapToChannelAttributes:
    (NSDictionary *)map;

+ (AgoraRtmChannelAttributeOptions *)mapToChannelAttributeOptions:
    (NSDictionary *)map;

+ (AgoraRtmLocalInvitation *)mapToLocalInvitation:(NSDictionary *)map;

+ (NSDictionary *)rtmMessageToMap:(AgoraRtmMessage *)message;

+ (NSDictionary *)rtmMemberToMap:(AgoraRtmMember *)member;

+ (NSDictionary *)localInvitationToMap:
    (AgoraRtmLocalInvitation *)localInvitation;

+ (NSDictionary *)remoteInvitationToMap:
    (AgoraRtmRemoteInvitation *)remoteInvitation;

+ (NSDictionary *)rtmAttributeToMap:(AgoraRtmAttribute *)attribute;

+ (NSDictionary *)rtmChannelAttributeToMap:
    (AgoraRtmChannelAttribute *)attribute;

@end

NS_ASSUME_NONNULL_END
