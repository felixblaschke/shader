#version 320 es

precision highp float;

layout(location = 0) out vec4 fragColor;

layout(location = 0) uniform float scale;
layout(location = 1) uniform sampler2D image;

void main() {
  vec2 coords = (0.0015 / scale) * (gl_FragCoord.xy);
  vec4 textureColor = texture(image, coords);
  fragColor = textureColor;
}