<div align="center">

# Aurora

**Six original fragment shaders for Flutter.**  
Live in a gallery, tunable, exportable.


![Aurora gallery](docs/gallery.gif)

</div>

---

## What this is

A gallery of six animated gradient shaders, written from scratch in GLSL and
running live on every screen. Tap a tile to view it full-screen, tune its
speed, intensity, and colors, then export the source and Dart wiring to your
clipboard.

Every shader is original. No Shadertoy ports, no copied math — the noise
functions, domain warping, and color mixing are all written for this project.

<table>
<tr>
<td width="33%">

**Aurora**  
Domain-warped fBm with a vertical falloff

![Aurora](docs/aurora.gif)

</td>
<td width="33%">

**Nebula**  
Radial glow layered over fBm

![Nebula](docs/nebula.gif)

</td>
<td width="33%">

**Plasma**  
Layered sine interference

![Plasma](docs/plasma.gif)

</td>
</tr>
<tr>
<td width="33%">

**Ripple**  
Noise-warped radial rings

![Ripple](docs/ripple.gif)

</td>
<td width="33%">

**Ember**  
Scrolling heat field with a flicker

![Ember](docs/ember.gif)

</td>
<td width="33%">

**Prism**  
Angular band interference

![Prism](docs/prism.gif)

</td>
</tr>
</table>

---

## How it works

Six live shaders sound expensive. They aren't, if you get the orchestration
right.

**One ticker, one notifier, zero widget rebuilds.** A single `Ticker` in
`AuroraApp` updates a `ValueNotifier<double>` once per frame. Every shader
reads it through `CustomPainter`'s `repaint` argument, which repaints without
rebuilding the widget tree. Sixty frames per second, zero `build` calls.

**One `RepaintBoundary` per tile.** When tile #3 repaints, tiles #1, #2, and
#4–6 keep their existing layers. Without this, every shader's repaint would
invalidate the whole scroll view.

**Visibility-gated rendering.** Off-screen tiles stop forwarding ticks
through a `RepaintGate`. The notifier keeps ticking; the painter stops
listening. Scrolling a grid of live shaders costs the same as scrolling a
grid of static ones.

```dart
// The 11-slot uniform contract every shader shares.
// Positional, not by name — vec2 consumes 2 slots, vec3 consumes 3.
shader.setFloat(0, size.width);      // uSize.x
shader.setFloat(1, size.height);     // uSize.y
shader.setFloat(2, time);            // uTime
shader.setFloat(3, params.speed);    // uSpeed
shader.setFloat(4, params.intensity);// uIntensity
shader.setFloat(5, params.colorA.r); // uColorA.r
// … slots 6–10
