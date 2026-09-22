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
float fbm(vec2 p) {
  float v = 0.0, a = 0.5;
  for (int i = 0; i < 6; i++) { v += a * noise(p); p *= 2.0; a *= 0.5; }
  return v;
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float aspect = uSize.x / uSize.y;
  vec2 p = (uv - 0.5) * vec2(aspect, 1.0);

  float t = uTime * uSpeed * 0.1;
  float d = length(p);
  float n = fbm(p * 3.0 + t);

  float glow = pow(max(0.0, 1.0 - d * 1.4), 2.5) * (0.6 + 0.8 * n);
  vec3 col = mix(uColorA, uColorB, n);
  col = mix(vec3(0.02, 0.02, 0.04), col, glow * uIntensity);
  col += pow(max(0.0, 1.0 - d * 3.5), 6.0) * 0.6 * uIntensity;

  fragColor = vec4(col, 1.0);
}