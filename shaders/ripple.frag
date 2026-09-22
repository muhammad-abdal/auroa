#version 460 core
#include <flutter/runtime_effect.glsl>
// slots: 0,1 uSize | 2 uTime | 3 uSpeed | 4 uIntensity | 5,6,7 uColorA | 8,9,10 uColorB
uniform vec2  uSize;
uniform float uTime;
uniform float uSpeed;
uniform float uIntensity;
uniform vec3  uColorA;
uniform vec3  uColorB;

out vec4 fragColor;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
  vec2 i = floor(p), f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1, 0)), u.x),
             mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), u.x), u.y);
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float aspect = uSize.x / uSize.y;
  vec2 p = (uv - 0.5) * vec2(aspect, 1.0);

  float t = uTime * uSpeed;
  float d = length(p);
  float warp = noise(p * 4.0 + t * 0.2) * 0.15;
  float w = sin((d * 14.0 - warp * 10.0) - t * 2.0);
  float ring = smoothstep(0.2, 1.0, w) * exp(-d * 2.0);

  vec3 col = mix(uColorA, uColorB, 0.5 + 0.5 * w);
  col = mix(vec3(0.02, 0.02, 0.04), col, ring * uIntensity);

  fragColor = vec4(col, 1.0);
}