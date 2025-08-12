# libjuice

This is [libjuice](https://github.com/paullouisageneau/libjuice), packaged for Zig.

## Installation

First, update your `build.zig.zon`:

```
# Initialize a `zig build` project if you haven't already
zig init
zig fetch --save git+https://github.com/lukaskastern/libjuice.git#1.6.1
```

You can then import `libjuice` in your `build.zig` with:

```zig
const libjuice_dependency = b.dependency("libjuice", .{
    .target = target,
    .optimize = optimize,
});
your_exe.linkLibrary(libjuice_dependency.artifact("juice"));
```

And use the library like this:
```zig
const juice = @cImport({
    @cInclude("juice/juice.h");
});

...
```

### Zig Version
The target zig version is 0.14.0
