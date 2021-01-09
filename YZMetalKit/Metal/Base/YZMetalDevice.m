//
//  YZMetalDevice.m
//  YZMetalLib
//
//  Created by yanzhen on 2020/12/11.
//

#import "YZMetalDevice.h"
#import "YZBrightnessString.h"
#import "YZVertexFragment.h"

@interface YZMetalDevice ()
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;

@property (nonatomic, strong) id<MTLLibrary> defaultLibrary;
@end

@implementation YZMetalDevice {
    /** 保证渲染线程安全
     1. filter
     */
    dispatch_semaphore_t _videoSemaphore;
}
static id _metalDevice;

+ (instancetype)defaultDevice
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _metalDevice = [[self alloc] init];
    });
    return _metalDevice;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _metalDevice = [super allocWithZone:zone];
    });
    return _metalDevice;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _metalDevice;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _videoSemaphore = dispatch_semaphore_create(1);
        _device = MTLCreateSystemDefaultDevice();
        _commandQueue = [_device newCommandQueue];
        //BOOL support = MPSSupportsMTLDevice(_device);
        
        _defaultLibrary = [_device newLibraryWithSource:[NSString stringWithUTF8String:YZVertexFragment] options:NULL error:nil];
        assert(_defaultLibrary);
    }
    return self;
}

#pragma mark - metal
- (id<MTLCommandBuffer>)commandBuffer {
    return [_commandQueue commandBuffer];
}

+ (MTLRenderPassDescriptor *)newRenderPassDescriptor:(id<MTLTexture>)texture {
    MTLRenderPassDescriptor *desc = [[MTLRenderPassDescriptor alloc] init];
    desc.colorAttachments[0].texture = texture;
    desc.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    desc.colorAttachments[0].storeAction = MTLStoreActionStore;
    desc.colorAttachments[0].loadAction = MTLLoadActionClear;
    return desc;
}

- (id<MTLRenderPipelineState>)newRenderPipeline:(NSString *)vertex fragment:(NSString *)fragment {
    if ([vertex isEqualToString:@"YZInputVertex"]) {
        return [self defaultRenderPipeline:vertex fragment:fragment];
    }
    return nil;
}

- (id<MTLRenderPipelineState>)defaultRenderPipeline:(NSString *)vertex fragment:(NSString *)fragment {
    id<MTLFunction> vertexFunction = [_defaultLibrary newFunctionWithName:vertex];
    id<MTLFunction> fragmentFunction = [_defaultLibrary newFunctionWithName:fragment];
    MTLRenderPipelineDescriptor *desc = [[MTLRenderPipelineDescriptor alloc] init];
    desc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;//bgra
    desc.rasterSampleCount = 1;
    desc.vertexFunction = vertexFunction;
    desc.fragmentFunction = fragmentFunction;
    
    NSError *error = nil;
    id<MTLRenderPipelineState> pipeline = [_device newRenderPipelineStateWithDescriptor:desc error:&error];
    if (error) {
        NSLog(@"YZMetalDevice new renderPipelineState failed: %@", error);
    }
    return pipeline;
}
#pragma mark - semaphore
+ (void)semaphoreSignal {
    [[self defaultDevice] signalSemaphore];
}

+ (intptr_t)semaphoreWaitNow {
    return [[self defaultDevice] waitNowSemaphore];
}

+ (void)semaphoreWaitForever {
    [[self defaultDevice] waitForeverSemaphore];
}
//private
- (void)signalSemaphore {
    dispatch_semaphore_signal(_videoSemaphore);
}

- (intptr_t)waitNowSemaphore {
    return dispatch_semaphore_wait(_videoSemaphore, DISPATCH_TIME_NOW);
}

- (void)waitForeverSemaphore {
    dispatch_semaphore_wait(_videoSemaphore, DISPATCH_TIME_FOREVER);
}
@end
