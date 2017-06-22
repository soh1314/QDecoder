//
//  ViewController.m
//  QDecoder
//
//  Created by user on 2017/6/22.
//  Copyright © 2017年 user. All rights reserved.
//

#import "ViewController.h"
#import "QDecoder.h"
#import "UIImage+Buffer.h"

@interface ViewController ()<QDecorderDelegate>

@property (nonatomic,strong)QDecoder *decoder;

@property (nonatomic,strong)UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200*640/480, 220)];
    self.imageView .contentMode = UIViewContentModeScaleAspectFill;
    self.imageView .clipsToBounds = YES;
    [self.view addSubview:self.imageView];
    
    NSURL *url  = [[NSBundle mainBundle] URLForResource:@"5" withExtension:@"mp4"];
    self.decoder = [QDecoder new];
    self.decoder.delegate = self;
    self.decoder.path = [url path];
    
    self.decoder.decordType = QHardWareDecode;
    
    NSOperationQueue *queue = [NSOperationQueue new];
    [self.decoder startExecutionBlock];
    [queue addOperation:self.decoder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)decodeSegmentFinish:(QDecoder *)decoder {
    CMSampleBufferRef bufferRef = decoder.bufferRef;
    CGImageRef cgimage = [UIImage cgImageFromSampleBufferRef:bufferRef];
    if (cgimage) {
        __weak typeof(self) weakSelf = self;
        weakSelf.imageView.layer.contents = (__bridge id _Nullable)(cgimage);
        CGImageRelease(cgimage);
    }
    CFRelease(bufferRef);
}

- (void)decodeCancel:(QDecoder *)decoder {
    
}

- (void)prepareDecode:(QDecoder *)decoder {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
