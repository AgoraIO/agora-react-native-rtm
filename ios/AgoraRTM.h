//
//  AgoraRTM.h
//  AgoraRTM
//
//  Created by Matrixbirds on 2019/5/27.
//

#ifndef AgoraRTM_h
#define AgoraRTM_h

#import <AgoraRtmKit/AgoraRtmKit.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface AgoraRTM : RCTEventEmitter <RCTBridgeModule, AgoraRtmChannelDelegate,
                                       AgoraRtmDelegate, AgoraRtmCallDelegate>
- (void)sendEvent:(NSString *)msg params:(NSArray *)params;
@end

#endif /* AgoraRTM_h */
