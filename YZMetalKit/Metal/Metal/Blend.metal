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
    
    float2 uv = fragmentInput.textureCoordinate;
    float4 uniform = float4(0.5,0.0,0.5,0.5);

    constexpr sampler quadSampler2;
    half4 textureColor2 = inputTexture2.sample(quadSampler2, fragmentInput.textureCoordinate2);
    
    bool includeX = uv.x >= uniform.x && uv.x <= (uniform.x + uniform.z);
    bool includeY = uv.y >= uniform.y && uv.y <= (uniform.y + uniform.w);
    
    if (includeX && includeY) {
        uv.x = (uv.x - uniform.x) * (1/uniform.z);
        uv.y = (uv.y - uniform.y) * (1/uniform.w);
        
        constexpr sampler quadSampler;
        half4 textureColor = inputTexture.sample(quadSampler, uv);
        return mix(textureColor, textureColor2, half(0.5));
    } else {
        return textureColor2 * half(1.0);
    }
}

//fragment half4 YZBlendFragment(YZBlendVertexIO fragmentInput [[stage_in]],
//                                     texture2d<half> inputTexture [[texture(YZBlendFragmentIndexY)]],
//                                     texture2d<half> inputTexture2 [[texture(YZBlendFragmentIndexUV)]])
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
//        return textureColor2 * half(1.0);
//    }
//    return mix(textureColor, textureColor2, half(0.5));
//}
