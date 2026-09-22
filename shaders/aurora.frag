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

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
             mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 5; i++) {
    v += a * noise(p);
    p *= 2.0;
    a *= 0.5;
  }
  return v;
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float aspect = uSize.x / uSize.y;
  vec2 p = (uv - 0.5) * vec2(aspect, 1.0);

  float t = uTime * uSpeed * 0.5;

  vec2 q = vec2(fbm(p * 2.0 + t * 0.15),
                fbm(p * 2.0 + vec2(5.2, 1.3)));
  vec2 r = vec2(fbm(p * 2.0 + q * 2.0 + vec2(1.7, 9.2) + t * 0.1),
                fbm(p * 2.0 + q * 2.0 + vec2(8.3, 2.8)));

  float n = fbm(p + r * 1.5);

  float band = smoothstep(0.30, 0.90, n + 0.40 * sin(p.x * 3.0 + t * 0.5));
  band *= smoothstep(-0.60, 0.40, -p.y);

  vec3 col = mix(uColorA, uColorB, n);
  col = mix(vec3(0.03, 0.03, 0.05), col, band * uIntensity);
  col *= smoothstep(1.2, 0.3, length(p));

  fragColor = vec4(col, 1.0);
}