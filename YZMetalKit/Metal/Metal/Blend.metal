//
//  Blend.metal
//  YZMetalKit
//
//  Created by yanzhen on 2021/1/26.
//

#include <metal_stdlib>
#import "YZShaderTypes.h"

using namespace metal;

struct YZBlendVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
    float2 textureCoordinate2 [[user(texturecoord2)]];
};


vertex YZBlendVertexIO YZBlendVertex(const device packed_float2 *position [[buffer(YZBlendVertexIndexPosition)]],
                                       const device packed_float2 *texturecoord [[buffer(YZBlendVertexIndexY)]],
                                       const device packed_float2 *texturecoord2 [[buffer(YZBlendVertexIndexUV)]],
                                       uint vertexID [[vertex_id]])
{
    YZBlendVertexIO outputVertices;
    
    outputVertices.position = float4(position[vertexID], 0, 1.0);
    outputVertices.textureCoordinate = texturecoord[vertexID];
    outputVertices.textureCoordinate2 = texturecoord2[vertexID];

    return outputVertices;
}

fragment half4 YZBlendFragment(YZBlendVertexIO fragmentInput [[stage_in]],
                                     texture2d<half> inputTexture [[texture(YZBlendFragmentIndexY)]],
                                     texture2d<half> inputTexture2 [[texture(YZBlendFragmentIndexUV)]])
{
    constexpr sampler quadSampler;
    float2 uv = fragmentInput.textureCoordinate;
    if (uv.x > 0.5) {
        uv.x = (uv.x - 0.5) * 2.0;
    }

    if (uv.y < 0.5) {
        uv.y = uv.y * 2.0;
    }
    half4 textureColor = inputTexture.sample(quadSampler, uv);

    constexpr sampler quadSampler2;
    half4 textureColor2 = inputTexture2.sample(quadSampler2, fragmentInput.textureCoordinate2);
    
    if (fragmentInput.textureCoordinate.x < 0.5 || fragmentInput.textureCoordinate.y > 0.5) {
        return textureColor2;
    }
    return mix(textureColor, textureColor2, half(1));
}

//typedef struct
//{
//    float mixturePercent;
//} DissolveBlendUniform;
//
//fragment half4 dissolveBlendFragment(YZBlendVertexIO fragmentInput [[stage_in]],
//                                     texture2d<half> inputTexture [[texture(0)]],
//                                     texture2d<half> inputTexture2 [[texture(1)]],
//                                     constant DissolveBlendUniform& uniform [[ buffer(1) ]])
//{
//    constexpr sampler quadSampler;
//    float2 uv = fragmentInput.textureCoordinate;
//    if (uv.x > 0.5) {
//        uv.x = (uv.x - 0.5) * 2.0;
//    }
//
//    if (uv.y < 0.5) {
//        uv.y = uv.y * 2.0;
//    }
//    half4 textureColor = inputTexture.sample(quadSampler, uv);
//
//    constexpr sampler quadSampler2;
//    half4 textureColor2 = inputTexture2.sample(quadSampler2, fragmentInput.textureCoordinate2);
//
//    if (fragmentInput.textureCoordinate.x < 0.5 || fragmentInput.textureCoordinate.y > 0.5) {
//        return textureColor2 * half(uniform.mixturePercent);
//    }
//    return mix(textureColor, textureColor2, half(uniform.mixturePercent));
//}
