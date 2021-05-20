//
//  SimulatorWindowStreamer.m
//  ObjcPlayground
//
//  Created by Tomasz Bartkowski on 15/05/2021.
//

#import "SimulatorWindowStreamer.h"

@implementation SimulatorWindowStreamer {
    uint32_t _windowId;
    NSTimer *timer;
    RTCDataChannel *_dataChannel;
}

- (id)initWithWithWindowId:(int)windowId
               dataChannel:(RTCDataChannel *)dataChannel
{
    self = [super init];
    
    if (self) {
        _dataChannel = dataChannel;
        _windowId = windowId;
    }
    return self;
}

- (void)start {
    NSDate *date = [[NSDate now] dateByAddingTimeInterval:2];
    
    timer = [[NSTimer alloc] initWithFireDate: date interval:1/30 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)timerAction: (NSTimer *) sender {
    CGImageRef image = CGWindowListCreateImage(
        CGRectMake(0, 57, 360, 640),
        kCGWindowListOptionIncludingWindow,
        _windowId,
        kCGWindowImageNominalResolution | kCGWindowImageBoundsIgnoreFraming
    );
    
    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, 0);
    CGImageDestinationRef destination = CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, nil);

    CFDictionaryRef options = (__bridge CFDictionaryRef)@{ (__bridge NSString *)kCGImageDestinationLossyCompressionQuality: @0.5};

    CGImageDestinationAddImage(destination, image, options);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    CGImageRelease(image);
    
    NSData *nsData = (__bridge NSData * _Nonnull)(data);
    RTCDataBuffer *buffer = [[RTCDataBuffer alloc] initWithData: nsData isBinary: true];
    [_dataChannel sendData: buffer];
    CFRelease(data);
}

@end
