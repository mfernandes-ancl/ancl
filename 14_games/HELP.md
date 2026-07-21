# ANCL Games

ANCL was built for industrial protocols and for writing ANCL itself — but the same tiny,
zero-dependency, native compiler builds anything. Here are some games, each a single native
`.exe` (no runtime, no engine) **with full source included**.

## Play

The fastest way in is **`aethercade.exe`** — a retro game-console launcher (also pure ANCL). It
lists every game as a cartridge; use **Up/Down** to pick one and **Enter** to play, **Esc** to quit.

```
aethercade.exe                     # the arcade shell — launches any game below
```

Or run any game directly from its own folder:

```
tetris\tetris.exe
snake\snake.exe
breakout\breakout.exe
aether_sand\aether_sand.exe        # a falling-sand playground
cosmic_vector\cosmic_vector.exe    # a vector-graphics shooter
aether_blocks\aether_blocks.exe    # a Minecraft-style voxel sandbox (3D)
aether_run\aether_run.exe          # a first-person 3D maze runner
```

`aether_blocks` and `aether_run` are little **3D** showcases — a voxel world and a first-person
maze, software-rendered, in the same zero-dependency ANCL.

## Source included — and it compiles

Every game folder has the game's `.ancl` source plus the two small library files it uses
(`numfmt.ancl`, `win32_api.ancl`), so you can rebuild it with the ANCL compiler:

```
anclc tetris\tetris.ancl tetris.exe
```

The launcher rebuilds the same way (`anclc aethercade.ancl aethercade.exe`), and the 3D games too
(`aether_blocks` compiles from `main.ancl`, which pulls in its two sibling modules).

That's the whole point: a native Windows game — GUI, 3D software renderer, and a console-style
launcher — in a few hundred lines of a language with **no runtime and no dependencies**.

## License

MIT © Mário Fernandes. See `LICENSE`.
