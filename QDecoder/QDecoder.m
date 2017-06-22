//
//  QDecoder.m
//  QDecoder
//
//  Created by user on 2017/6/22.
//  Copyright © 2017年 user. All rights reserved.
//

#import "QDecoder.h"

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface QDecoder ()

@property (nonatomic,strong)AVAssetReader *videoReader;
@property (nonatomic,strong)AVAssetReaderTrackOutput *readerOutput;
@property (nonatomic,strong)AVAssetTrack *videoTrack;
@property (nonatomic,strong)CADisplayLink *displayLinker;

@property (nonatomic,assign)NSTimeInterval timeInterval;
@property (nonatomic,assign)NSInteger failCount;

@end

@implementation QDecoder


- (instancetype)initWithPath:(NSString *)path {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)startExecutionBlock {
    __weak typeof(self) weakSelf = self;
    [self addExecutionBlock:^{
        [weakSelf decode];
    }];
}

- (void)decode {
    [self decode:self.decordType];
}

- (void)decode:(QDecoderType)type {
    [self prepareDecode];
    [self internalDecode];
}

#pragma mark - video private method

- (NSTimeInterval)timeInterval {
    return self.videoTrack.minFrameDuration.value *1.0/self.videoTrack.minFrameDuration.timescale;
}

- (void)prepareDecode {
    self.sourceUrl = [NSURL fileURLWithPath:self.path];
    AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:self.sourceUrl options:nil];
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (!videoTracks.count) {
        NSLog(@"QDecoder warning : prepareDecode check videoTrack count == 0");
    }
    NSError *error = nil;
    self.videoReader = [[AVAssetReader alloc]initWithAsset:asset error:&error];
    AVAssetTrack *firstTrack = [videoTracks firstObject];
    self.videoTrack = firstTrack;
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    int m_pixelFormatType = kCVPixelFormatType_32BGRA;
    [options setObject:@(m_pixelFormatType) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    AVAssetReaderTrackOutput *videoReaderOutput = [[AVAssetReaderTrackOutput alloc]initWithTrack:firstTrack outputSettings:options];
    self.readerOutput = videoReaderOutput;
    [self.videoReader addOutput:videoReaderOutput];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(prepareDecode:)]) {
        [self.delegate prepareDecode:self];
    }
}

- (void)internalDecode {
    [self.videoReader startReading];
    while ([self.videoReader status] == AVAssetReaderStatusReading && self.videoTrack.nominalFrameRate > 0 && ![self isCancelled]) {
        
        // 读取 video sample
        self.bufferRef = [self.readerOutput copyNextSampleBuffer];
        /** 存储视频每一帧*/
        if (self.bufferRef != nil) {
            dispatch_main_async_safe(^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(decodeSegmentFinish:)]) {
                    [self.delegate decodeSegmentFinish:self];
                }
            });
        } else {
            self.failCount++;
        }
        if (self.failCount > 10) {
            NSLog(@"QDecoder warning : decode failcount > 10");
        }
        // 根据需要休眠一段时间；比如上层播放视频时每帧之间是有间隔的
        [NSThread sleepForTimeInterval:self.timeInterval];
    }
}



@end
