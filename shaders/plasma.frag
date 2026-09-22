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
  vec2 p = (uv - 0.5) * vec2(aspect, 1.0) * 3.0;

  float t = uTime * uSpeed * 0.5;
  float v = sin(p.x + t)
          + sin(p.y + t * 0.8)
          + sin((p.x + p.y) * 1.5 + t * 1.2)
          + sin(length(p * 2.0) - t * 1.5);
  v *= 0.25;

  float m = smoothstep(-0.2, 0.6, v);
  vec3 col = mix(uColorA, uColorB, m);
  col *= 0.5 + 0.9 * uIntensity;
  col = mix(vec3(0.02, 0.02, 0.04), col, 0.35 + 0.65 * abs(v));

  fragColor = vec4(col, 1.0);
}