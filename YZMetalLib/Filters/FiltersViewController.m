//
//  FiltersViewController.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/2/18.
//

#import "FiltersViewController.h"
#import <YZMetalKit/YZMetalKit.h>

@interface FiltersViewController ()<YZFilterCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIView *player;
@property (weak, nonatomic) IBOutlet UIImageView *smallPlayer;


@property (nonatomic, strong) YZFilterCapture *capture;
@property (nonatomic, strong) CIContext *context;


@property (nonatomic, assign) BOOL cap;
@end

@implementation FiltersViewController {
    int8_t *_imageBuffer;
    NSUInteger _jpgLen;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _context = [CIContext contextWithOptions:nil];
    //1280x720
    //840x480 7x4  180x7=1260
    _capture = [[YZFilterCapture alloc] initWithSize:CGSizeMake(640, 480) front:YES];
    _capture.fillMode = YZFilterFillModeScaleAspectFit;
    _capture.player = self.player;
    _capture.delegate = self;
    [_capture startRunning];
    [NSTimer scheduledTimerWithTimeInterval:10 repeats:YES block:^(NSTimer * _Nonnull timer) {
        self.cap = YES;
    }];
    
}

- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark - YZFilterCaptureDelegate
-(void)videoCapture:(YZFilterCapture *)videoCapture outputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (self.cap) {
        self.cap = NO;
        [self showPixelBuffer:pixelBuffer];
    }
}

/**
 1. 线程送出jpg数据
 
 //todo - test
 2. context直接转data
 */
- (void)showPixelBuffer:(CVPixelBufferRef)pixel {
    CVPixelBufferRetain(pixel);
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:pixel];
    size_t width = CVPixelBufferGetWidth(pixel);
    size_t height = CVPixelBufferGetHeight(pixel);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef videoImageRef = [context createCGImage:ciImage fromRect:CGRectMake(0, 0, width, height)];
    UIImage *image = [UIImage imageWithCGImage:videoImageRef];
    NSData *data = UIImageJPEGRepresentation(image, 1);
    //UIImage *jpgImage = [UIImage imageWithData:data];
    CGImageRelease(videoImageRef);
    CVPixelBufferRelease(pixel);
    [self reportJPGData:data];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.smallPlayer.image = jpgImage;
//    });
}

- (void)reportJPGData:(NSData *)data {
    if (_jpgLen < data.length) {
        if (_imageBuffer) {
            free(_imageBuffer);
        }
        _jpgLen = data.length;
        _imageBuffer = malloc(_jpgLen);
    }
    memcpy(_imageBuffer, data.bytes, data.length);
//    [self testDisPlayImage:data.length];
}

- (void)testDisPlayImage:(NSUInteger)len {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *data = [[NSData alloc] initWithBytes:_imageBuffer length:len];
        UIImage *jpgImage = [UIImage imageWithData:data];
        self.smallPlayer.image = jpgImage;
    });
}



//keep
- (void)showPixelBuffer_keep:(CVPixelBufferRef)pixel {
    CVPixelBufferRetain(pixel);
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:pixel];
    size_t width = CVPixelBufferGetWidth(pixel);
    size_t height = CVPixelBufferGetHeight(pixel);
    CGImageRef videoImageRef = [_context createCGImage:ciImage fromRect:CGRectMake(0, 0, width, height)];
    UIImage *image = [UIImage imageWithCGImage:videoImageRef];
#if 1
    //NSData * data = UIImagePNGRepresentation(image);
    
    
    NSData * data = UIImageJPEGRepresentation(image, 1);
    UIImage * jpgImage = [UIImage imageWithData:data];
        
    // 保存至相册
//    UIImageWriteToSavedPhotosAlbum(jpgImage, nil, nil, nil);
    
#endif
    CGImageRelease(videoImageRef);
    CVPixelBufferRelease(pixel);
    
    
//    NSLog(@"width:%d:%d", width, height);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.smallPlayer.image = image;
    });
}
#pragma mark - system
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

@end
