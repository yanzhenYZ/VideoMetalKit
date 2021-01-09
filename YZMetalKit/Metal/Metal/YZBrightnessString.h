//
//  YZBrightnessString.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/1/9.
//

#import <Foundation/Foundation.h>

const char* YZBeautyString =
"using namespace metal;\n"

"constant half3x3 saturateMatrix = half3x3(half3(1.1102,-0.0598,-0.061),half3(-0.0774,1.0826,-0.1186),half3(-0.0228,-0.0228,1.1772));\n"
"constant half3 W = half3(0.299, 0.587, 0.114);\n"

"struct YZBrightnessVertexIO\n"
"{\n"
"    float4 position [[position]];\n"
"    float2 textureCoordinate;\n"
"};\n"

"typedef struct\n"
"{\n"
"    float brightLevel;\n"
"    float beautyLevel;\n"
"} YZBrightnessUniform;\n"

"half hardLight(half pass) {\n"
"    half highPass = pass;\n"
"    for (int i = 0; i < 5; i++) {\n"
"        if (pass <= 0.5) {\n"
"            highPass = pass * pass * 2.0;\n"
"        } else {\n"
"            highPass = 1.0 - ((1.0 - pass) * (1.0 - pass) * 2.0);\n"
"        }\n"
"    }\n"
"    return highPass;\n"
"}\n"

"vertex YZBrightnessVertexIO YZBrightnessInputVertex(const device packed_float2 *position [[buffer(0)]], const device packed_float2 *texturecoord [[buffer(1)]], uint vertexID [[vertex_id]]) {\n"
"   YZBrightnessVertexIO outputVertices;\n"
"    outputVertices.position = float4(position[vertexID], 0, 1.0);\n"
"    outputVertices.textureCoordinate = texturecoord[vertexID];\n"
"    return outputVertices;\n"
"}\n"

"fragment half4 YZBrightnessFragment(YZBrightnessVertexIO fragmentInput [[stage_in]], texture2d<half> inputTexture [[texture(0)]], constant YZBrightnessUniform& uniform [[ buffer(0) ]]) {\n"
"    constexpr sampler quadSampler (mag_filter::linear, min_filter::linear);\n"
"    half3 centralColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate).rgb;\n"
"    half2 blur[24];\n"
"    half2 singleStepOffset = half2(0.0018518518, 0.0012722646);\n"
"    half2 xy = half2(fragmentInput.textureCoordinate.xy);\n"
"    blur[0] = xy + singleStepOffset * half2(0.0, -10.0);\n"
"    blur[1] = xy + singleStepOffset * half2(0.0, 10.0);\n"
"    blur[2] = xy + singleStepOffset * half2(-10.0, 0.0);\n"
"    blur[3] = xy + singleStepOffset * half2(10.0, 0.0);\n"
"    blur[4] = xy + singleStepOffset * half2(5.0, -8.0);\n"
"    blur[5] = xy + singleStepOffset * half2(5.0, 8.0);\n"
"    blur[6] = xy + singleStepOffset * half2(-5.0, 8.0);\n"
"    blur[7] = xy + singleStepOffset * half2(-5.0, -8.0);\n"
"    blur[8] = xy + singleStepOffset * half2(8.0, -5.0);\n"
"    blur[9] = xy + singleStepOffset * half2(8.0, 5.0);\n"
"    blur[10] = xy + singleStepOffset * half2(-8.0, 5.0);\n"
"    blur[11] = xy + singleStepOffset * half2(-8.0, -5.0);\n"
"    blur[12] = xy + singleStepOffset * half2(0.0, -6.0);\n"
"    blur[13] = xy + singleStepOffset * half2(0.0, 6.0);\n"
"    blur[14] = xy + singleStepOffset * half2(6.0, 0.0);\n"
"    blur[15] = xy + singleStepOffset * half2(-6.0, 0.0);\n"
"    blur[16] = xy + singleStepOffset * half2(-4.0, -4.0);\n"
"    blur[17] = xy + singleStepOffset * half2(-4.0, 4.0);\n"
"    blur[18] = xy + singleStepOffset * half2(4.0, -4.0);\n"
"    blur[19] = xy + singleStepOffset * half2(4.0, 4.0);\n"
"    blur[20] = xy + singleStepOffset * half2(-2.0, -2.0);\n"
"    blur[21] = xy + singleStepOffset * half2(-2.0, 2.0);\n"
"    blur[22] = xy + singleStepOffset * half2(2.0, -2.0);\n"
"    blur[23] = xy + singleStepOffset * half2(2.0, 2.0);\n"
"    half g = centralColor.g * 22.0;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[0])).g;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[1])).g;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[2])).g;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[3])).g;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[4])).g;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[5])).g;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[6])).g;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[7])).g;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[8])).g;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[9])).g;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[10])).g;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[11])).g;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[12])).g * 2.0;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[13])).g * 2.0;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[14])).g * 2.0;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[15])).g * 2.0;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[16])).g * 2.0;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[17])).g * 2.0;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[18])).g * 2.0;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[19])).g * 2.0;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[20])).g * 2.0;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[21])).g * 2.0;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[22])).g * 2.0;\n"
"    g += inputTexture.sample(quadSampler, float2(blur[23])).g * 2.0;\n"
"    g = g / 62.0;\n"
"    half highPass = centralColor.g - g + 0.5;\n"
"    highPass = hardLight(highPass);\n"
"    half lumance = dot(centralColor, W);\n"
"    half beauty = uniform.beautyLevel;\n"
"    half tone = 0.5;\n"
"    half4 params;\n"
"    params.r = 1.0 - 0.6 * beauty;\n"
"    params.g = 1.0 - 0.3 * beauty;\n"
"    params.b = 0.1 + 0.3 * tone;\n"
"    params.a = 0.1 + 0.3 * tone;\n"
"    half alpha = pow(lumance, params.r);\n"
"    half3 smoothColor = centralColor + (centralColor - highPass) * alpha * 0.1;\n"
"    smoothColor.r = clamp(pow(smoothColor.r, params.g), half(0.0), half(1.0));\n"
"    smoothColor.g = clamp(pow(smoothColor.g, params.g), half(0.0), half(1.0));\n"
"    smoothColor.b = clamp(pow(smoothColor.b, params.g), half(0.0), half(1.0));\n"
"    half3 lvse = 1.0 - (1.0 - smoothColor) * (1.0 - centralColor);\n"
"    half3 bianliang = max(smoothColor, centralColor);\n"
"    half3 rouguang = 2.0 * centralColor * smoothColor + centralColor * centralColor - 2.0 * centralColor * centralColor * smoothColor;\n"
"    half4 color = half4(mix(centralColor, lvse, alpha), 1.0);\n"
"    color.rgb = mix(color.rgb, bianliang, alpha);\n"
"    color.rgb = mix(color.rgb, rouguang, params.b);\n"
"    half3 satcolor = color.rgb * saturateMatrix;\n"
"    color.rgb = mix(color.rgb, satcolor, params.a);\n"
"    float brightness = uniform.brightLevel * 0.3;\n"
"    return half4(color.rgb + brightness, color.a);\n"
"}\n";
