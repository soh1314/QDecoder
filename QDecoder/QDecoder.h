//
//  QDecoder.h
//  QDecoder
//
//  Created by user on 2017/6/22.
//  Copyright © 2017年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class QDecoder;
@protocol QDecorderDelegate <NSObject>

- (void)decodeSegmentFinish:(QDecoder *)decoder;

- (void)decodeCancel:(QDecoder *)decoder;

- (void)prepareDecode:(QDecoder *)decoder;

- (void)decodeComplete:(QDecoder *)decoder;

@end

typedef enum : NSUInteger {
    QHardWareDecode,
    QSoftWareDecode
} QDecoderType;

typedef enum : NSUInteger {
    QVideoSource,
    QAudioSource
} QSourceType;

typedef enum : NSUInteger {
    QLocal,
    QNetwork
} QFileType;

@interface QDecoder : NSBlockOperation

@property (nonatomic,assign) QDecoderType decordType;
@property (nonatomic,assign) QSourceType sourceType;
@property (nonatomic,assign) QFileType fileType;
@property (nonatomic,copy)   NSString *path;

@property (nonatomic,assign) BOOL openDispalyLink;

@property (nonatomic,assign) NSInteger totalTime;
@property (nonatomic,strong) NSURL *sourceUrl;
@property (nonatomic,copy)   NSDictionary *option;

@property (nonatomic,assign)CMSampleBufferRef bufferRef;

@property (nonatomic,weak)id <QDecorderDelegate>delegate;

- (instancetype)initWithPath:(NSString *)path;

- (void)startExecutionBlock;

@end
