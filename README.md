# FLUX

**GPU-accelerated UI framework for Zig**

FLUX is a UI framework for building high-performance desktop applications. It combines declarative UI definition with GPU-accelerated rendering via BLAZE.

## Target Use Cases

- Engineering software (forms, data tables, visualizations)
- Game UI (HUD, menus, debug tools)
- Desktop tools and utilities

## Design Philosophy

FLUX is **hybrid immediate/retained**:

1. **Declarative views** - You describe what UI should look like given state
2. **Retained structure** - FLUX maintains element tree, diffs on updates
3. **Immediate rendering** - Each frame, visible elements emit draw commands
4. **GPU-batched drawing** - All UI primitives batched into minimal draw calls

## Key Features

- **Comptime Element Trees** - Elements are comptime-known types, not heap-allocated trait objects. No allocations for UI tree, perfect cache locality.
- **Inline Styles** - Styles are comptime structs, not runtime-parsed strings.
- **Arena Allocation** - Frame-scoped arena allocation for temporary UI data, freed in bulk at frame end.
- **SDF Text Rendering** - Crisp text at any scale via signed distance fields.
- **Flexbox Layout** - Familiar layout model for positioning elements.

## Design Principles

1. Comptime over runtime
2. Explicit over implicit
3. Data-oriented design
4. Zero-cost abstractions
5. Incremental complexity

## Dependencies

- [BLAZE](https://github.com/hotschmoe/blaze) - GPU abstraction layer

## Status

🚧 **Work in Progress** - Not ready for production use.

## License

MIT © hotschmoe

---

*Part of the [zig-graphics](https://github.com/hotschmoe/zig-graphics) stack: BLAZE → FORGE → FLUX*
