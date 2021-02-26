//
//  YZTestBeautyFilter.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/2/4.
//

#import "YZTestBeautyFilter.h"

@interface YZTestBeautyFilter ()
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLLibrary> defaultLibrary;

@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@end

@implementation YZTestBeautyFilter

- (instancetype)initWithDevice:(id<MTLDevice>)device
{
    self = [super init];
    if (self) {
        self.device = device;
        _commandQueue = [_device newCommandQueue];
        _defaultLibrary = [_device newDefaultLibrary];
        
        CVMetalTextureCacheCreate(NULL, NULL, device, NULL, &_textureCache);
        _pipelineState = [self newRenderPipeline:@"YZTestBrightnessInputVertex" fragment:@"YZTestBrightnessFragment"];
    }
    return self;
}

- (void)dealPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    CVMetalTextureRef tmpTexture = NULL;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, width, height, 0, &tmpTexture);
    if (status != kCVReturnSuccess) {
        //CVPixelBufferRelease(pixelBuffer);
        NSLog(@"1234XX___%d", status);
        return;
    }
    id<MTLTexture> texture = CVMetalTextureGetTexture(tmpTexture);
    CFRelease(tmpTexture);

    //two step
    MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm width:texture.width height:texture.height mipmapped:NO];
    desc.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget;
    id<MTLTexture> outputTexture = [self.device newTextureWithDescriptor:desc];
    [self renderTexture:texture outputTexture:outputTexture];
    
    //just test outout buffer
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *address = CVPixelBufferGetBaseAddress(pixelBuffer);
    NSUInteger bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [outputTexture getBytes:address bytesPerRow:bytesPerRow fromRegion:region mipmapLevel:0];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}


- (void)renderTexture:(id<MTLTexture>)texture outputTexture:(id<MTLTexture>)outputTexture {
    MTLRenderPassDescriptor *desc = [[MTLRenderPassDescriptor alloc] init];
    desc.colorAttachments[0].texture = outputTexture;
    desc.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    desc.colorAttachments[0].storeAction = MTLStoreActionStore;
    desc.colorAttachments[0].loadAction = MTLLoadActionClear;
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZBrightness render endcoder Fail");
        return;
    }
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.pipelineState];
    simd_float8 vertices = {-1, 1, 1, 1, -1, -1, 1, -1};
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    simd_float8 textureCoordinates = {0, 0, 1, 0, 0, 1, 1, 1};
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:texture atIndex:0];

    simd_float2 uniform = {0.5, 1};
    [encoder setFragmentBytes:&uniform length:sizeof(simd_float2) atIndex:0];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    
    
}

- (id<MTLRenderPipelineState>)newRenderPipeline:(NSString *)vertex fragment:(NSString *)fragment {
    id<MTLFunction> vertexFunction = [_defaultLibrary newFunctionWithName:vertex];
    id<MTLFunction> fragmentFunction = [_defaultLibrary newFunctionWithName:fragment];
    MTLRenderPipelineDescriptor *desc = [[MTLRenderPipelineDescriptor alloc] init];
    desc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;//bgra
    if (@available(iOS 11.0, macOS 10.13, *)) {//每个像素中的采样点数
        desc.rasterSampleCount = 1;
    } else {
        desc.sampleCount = 1;
    }
    desc.vertexFunction = vertexFunction;
    desc.fragmentFunction = fragmentFunction;
    
    NSError *error = nil;
    id<MTLRenderPipelineState> pipeline = [_device newRenderPipelineStateWithDescriptor:desc error:&error];
    if (error) {
        NSLog(@"YZMetalDevice new renderPipelineState failed: %@", error);
    }
    return pipeline;
}

- (void)dealloc {
    if (_textureCache) {
        CVMetalTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
        _textureCache = nil;
    }
}
@end
