//
//  SimulatorWindowStreamer.h
//  ObjcPlayground
//
//  Created by Tomasz Bartkowski on 15/05/2021.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <CoreVideo/CoreVideo.h>
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

@interface SimulatorWindowStreamer : NSObject

- (id)initWithWithWindowId:(int)windowId
               dataChannel:(RTCDataChannel *)dataChannel;
- (void)start;

@end

NS_ASSUME_NONNULL_END
