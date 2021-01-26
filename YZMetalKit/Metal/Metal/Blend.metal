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

typedef struct//必须四个每行
{
    float4 frame;
} YZBlendUniform;


vertex YZBlendVertexIO YZBlendVertex(const device packed_float2 *position [[buffer(YZBlendVertexIndexPosition)]],
                                       const device packed_float2 *texturecoord [[buffer(YZBlendVertexIndexVideo)]],
                                       const device packed_float2 *texturecoord2 [[buffer(YZBlendVertexIndexImage)]],
                                       uint vertexID [[vertex_id]])
{
    YZBlendVertexIO outputVertices;
    
    outputVertices.position = float4(position[vertexID], 0, 1.0);
    outputVertices.textureCoordinate = texturecoord[vertexID];
    outputVertices.textureCoordinate2 = texturecoord2[vertexID];

    return outputVertices;
}

fragment half4 YZBlendFragment(YZBlendVertexIO fragmentInput [[stage_in]],
                                     texture2d<half> inputTexture [[texture(YZBlendFragmentIndexVideo)]],
                                     texture2d<half> inputTexture2 [[texture(YZBlendFragmentIndexImage)]],
                                     constant YZBlendUniform& uniformI [[ buffer(YZUniformIndexNormal) ]])
{
    
    float2 uv = fragmentInput.textureCoordinate2;
    float4 frame = uniformI.frame;

    constexpr sampler quadSampler;
    half4 textureColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    bool includeX = uv.x >= frame.x && uv.x <= (frame.x + frame.z);
    bool includeY = uv.y >= frame.y && uv.y <= (frame.y + frame.w);
    
    if (includeX && includeY) {
        uv.x = (uv.x - frame.x) * (1/frame.z);
        uv.y = (uv.y - frame.y) * (1/frame.w);
        
        constexpr sampler quadSampler2;
        half4 textureColor2 = inputTexture2.sample(quadSampler2, uv);
        return half4(mix(textureColor.rgb, textureColor2.rgb, textureColor2.a), textureColor.a);
        //return half4(mix(textureColor.rgb, textureColor2.rgb, textureColor2.a * half(0.5)), textureColor.a);
    } else {
        return textureColor;
    }
}
