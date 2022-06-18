## Writing shaders

This section covers useful information and resources writing own shader code.

### Constraints in Flutter

Shaders are not supported for Flutter web, yet. But there is a [project plan](https://github.com/flutter/flutter/projects/207) for the Flutter engine developers to enable it.

Also the capabilities of GLSL language feature are restricted. Take a look at the [specifications of the SPIR-V Transpiler](https://github.com/flutter/engine/tree/master/lib/spirv). 

This package compiles GLSL code to SPIR-V code, and at runtime SPIR-V transpiler converts it to native API (e.g. OpenGL, Vulkan). So it might be that `shader` will compile fine, but it fails at runtime.

### Learning GLSL

There are various sources to learn GLSL:

- https://learnopengl.com/Getting-started/Shaders
- https://thebookofshaders.com/
- https://www.shadertoy.com/
- [https://www.reddit.com/.../best_place_to_start_learning_glsl/](https://www.reddit.com/r/shaders/comments/gu2yd9/best_place_to_start_learning_glsl/)
