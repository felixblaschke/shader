#version 320 es

precision highp float;

layout(location = 0) out vec4 fragColor;

layout(location = 0) uniform vec3 color;

void main() {
    fragColor = vec4(color.rgb, 1.0);
}