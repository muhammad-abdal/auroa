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

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float aspect = uSize.x / uSize.y;
  vec2 p = (uv - 0.5) * vec2(aspect, 1.0);

  float t = uTime * uSpeed * 0.3;
  float a = atan(p.y, p.x);
  float r = length(p);

  float bands = sin(a * 6.0 + r * 8.0 + t * 2.0);
  float m = smoothstep(-0.3, 0.7, bands) * smoothstep(1.0, 0.1, r);

  vec3 col = mix(uColorA, uColorB, 0.5 + 0.5 * bands);
  col = mix(vec3(0.02, 0.02, 0.04), col, m * uIntensity);

  fragColor = vec4(col, 1.0);
}