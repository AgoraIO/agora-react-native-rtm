//
//  AgoraRTM.h
//  AgoraRTM
//
//  Created by Matrixbirds on 2019/5/27.
//

#ifndef AgoraRTM_h
#define AgoraRTM_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <AgoraRtmKit/AgoraRtmKit.h>

@interface AgoraRTM : RCTEventEmitter <RCTBridgeModule, AgoraRtmChannelDelegate, AgoraRtmDelegate, AgoraRtmCallDelegate>
- (void)sendEvent:(NSString *)msg params:(NSDictionary *)params;
@end

#endif /* AgoraRTM_h */
