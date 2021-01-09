//
//  YZYUVToRGBConversion.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/1/9.
//

#import <Foundation/Foundation.h>

const char* YZYUVToRGBString =
"using namespace metal;\n"

"struct YZYUVToRGBVertexIO\n"
"{\n"
"    float4 position [[position]];\n"
"    float2 textureCoordinate [[user(texturecoord)]];\n"
"    float2 textureCoordinate2 [[user(texturecoord2)]];\n"
"};\n"

"vertex YZYUVToRGBVertexIO YZYUVToRGBVertex(const device packed_float2 *position [[buffer(0)]], const device packed_float2 *texturecoord [[buffer(1)]], const device packed_float2 *texturecoord2 [[buffer(2)]], uint vertexID [[vertex_id]]) {\n"
"    YZYUVToRGBVertexIO outputVertices;\n"
"    outputVertices.position = float4(position[vertexID], 0, 1.0);\n"
"    outputVertices.textureCoordinate = texturecoord[vertexID];\n"
"    outputVertices.textureCoordinate2 = texturecoord2[vertexID];\n"
"    return outputVertices;\n"
"}\n"

"typedef struct\n"
"{\n"
"    float3x3 colorConversionMatrix;\n"
"} YZYUVConversionUniform;\n"

"fragment half4 YZYUVConversionFullRangeFragment(YZYUVToRGBVertexIO fragmentInput [[stage_in]], texture2d<half> inputTexture [[texture(0)]], texture2d<half> inputTexture2 [[texture(1)]], constant YZYUVConversionUniform& uniform [[ buffer(0) ]]) {\n"
"    constexpr sampler quadSampler;\n"
"    half3 yuv;\n"
"    yuv.x = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate).r;\n"
"    yuv.yz = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate).rg - half2(0.5, 0.5);\n"
"    half3 rgb = half3x3(uniform.colorConversionMatrix) * yuv;\n"
"    return half4(rgb, 1.0);\n"
"}\n"

"fragment half4 YZYUVConversionVideoRangeFragment(YZYUVToRGBVertexIO fragmentInput [[stage_in]], texture2d<half> inputTexture [[texture(0)]], texture2d<half> inputTexture2 [[texture(1)]], constant YZYUVConversionUniform& uniform [[ buffer(0) ]]) {\n"
"    constexpr sampler quadSampler;\n"
"    half3 yuv;\n"
"    yuv.x = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate).r - (16.0/255.0);\n"
"    yuv.yz = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate).rg - half2(0.5, 0.5);\n"
"    half3 rgb = half3x3(uniform.colorConversionMatrix) * yuv;\n"
"    return half4(rgb, 1.0);\n"
"}\n";

