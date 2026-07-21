# ANCL Miscellaneous — demos & experiments

A grab-bag of native ANCL showcases — visual demos and experiments that show the language doing
things well beyond industrial protocols and IDEs. Each is a standalone `.exe` with source included,
zero-dependency.

## What's here

| Folder | What it is |
|---|---|
| `speech/` | native text-to-speech (Windows SAPI via COM) |
| `fluid_matrix/` | a real-time fluid simulation |
| `cyber_face/` | "chrome genesis" 3D face demos (two variants) |
| `ancl_3d/` | 3D engine demos — an interactive engine + a wireframe renderer |
| `aether_bloch/` | a Bloch-sphere / quantum-state visualizer |
| `aether_q/` | a small quantum demo |

## Run / rebuild

Run any `.exe` directly. Each folder includes the demo's source plus the few small library files
it needs, so you can rebuild any of them — just point `anclc` at the demo's `.ancl`:

```
anclc fluid_matrix\fluid_engine_3d.ancl  out.exe
anclc speech\speech.ancl                 speech.exe
```

Folders with several `.ancl` files each contain multiple independent demos (e.g. `ancl_3d` has an
interactive engine and a wireframe renderer) — compile whichever you like.

## License

MIT © Mário Fernandes. See `LICENSE`.
