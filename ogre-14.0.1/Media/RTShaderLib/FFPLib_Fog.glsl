/*
-----------------------------------------------------------------------------
This source file is part of OGRE
(Object-oriented Graphics Rendering Engine)
For the latest info, see http://www.ogre3d.org

Copyright (c) 2000-2014 Torus Knot Software Ltd
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
-----------------------------------------------------------------------------
*/

//-----------------------------------------------------------------------------
// Program Name: FFPLib_Fog
// Program Desc: Fog functions of the FFP.
// Program Type: Vertex/Pixel shader
// Language: GLSL
// Notes: Implements core functions needed by FFPFog class.
// Based on fog engine. 
// See http://msdn.microsoft.com/en-us/library/bb173398.aspx
// Vertex based fog: the w component of the out position is used
// as the distance parameter to fog formulas. This is basically the z coordinate
// in world space. See pixel fog under D3D docs. The fog factor is computed according 
// to each formula, then clamped and output to the pixel shader.
// Pixel based fog: the w component of the out position is passed to pixel shader
// that computes the fog factor based on it.
// Both techniques use the fog factor in the end of the pixel shader to blend
// the output color with the fog color.
//-----------------------------------------------------------------------------

#define FOG_EXP    1
#define FOG_EXP2   2
#define FOG_LINEAR 3

//-----------------------------------------------------------------------------
void FFP_FogFactor(in float depth,
				  in vec4 fogParams,				   
				  out float oFogFactor)
{
	float distance  = abs(depth);

#if FOG_TYPE == FOG_LINEAR
	float fogFactor = (fogParams.z - distance) * fogParams.w;
#elif FOG_TYPE == FOG_EXP
	float x       = distance*fogParams.x;
	float fogFactor = 1.0 / exp(x);
#elif FOG_TYPE == FOG_EXP2
	float x       = (distance*fogParams.x*distance*fogParams.x);
	float fogFactor = 1.0 / exp(x);
#endif

	oFogFactor  = saturate(fogFactor);
}

//-----------------------------------------------------------------------------
void FFP_PixelFog_PositionDepth(in mat4 mWorld, 
				   in vec3 cameraPos,
				   in vec4 pos, 				   				   				   
				   out vec3 oPosView,
				   out float oDepth)
{
	vec4 vOutPos  = mul(mWorld, pos);
	oPosView      = vOutPos.xyz - cameraPos;
	oDepth        = length(oPosView);	
}

//-----------------------------------------------------------------------------
void FFP_PixelFog(in float depth,
				   in vec4 fogParams,				   
				   in vec4 fogColor,
				   in vec4 baseColor,
				   out vec4 oColor)
{
	float fogFactor = 0.0;
	FFP_FogFactor(depth, fogParams, fogFactor);
	oColor = mix(fogColor, baseColor, fogFactor);
}