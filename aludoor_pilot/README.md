# ALU Door Pilot

This is a local proof-of-concept SketchUp Pro extension. It generates a simplified
single-leaf 100 mm aluminium swing door with separate frame, sash and glass groups,
plus a basic profile cutting list stored in the generated model.

It also includes a two-panel 74 mm C-groove sliding pilot based on the catalogue's
`ESD-1001`, `ESD-1501`, and `ESD-1502` profile families.

The cross-sections are deliberately simplified rectangular hollow sections using
the main catalogue envelopes. They are not production-certified extrusion geometry.

## Install

1. In SketchUp Pro, open **Extension Manager**.
2. Choose **Install Extension** and select `aludoor_pilot.rbz`.
3. Restart SketchUp if requested.
4. Use **Extensions > ALU Door Pilot > Generate single-leaf pilot**.

For the sliding test, use **Generate 74 mm C-Groove slider**.

## Pilot scope

- User-entered overall width and height.
- Simplified `100D-3105` frame members.
- Simplified `100D-101` sash members.
- Glass panel.
- Profile names and cut lengths saved as component attributes.
- Basic cutting list display.

For production, replace the simplified hollow sections with approved DXF profile
loops and add verified joint deductions, hardware machining, glazing and gasket rules.
