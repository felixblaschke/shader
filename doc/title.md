# shader

Shader manages the **compilation** of your GLSL shaders into SPIR-V byte code and Dart code.

**Quickstart**

```bash
# Install cli
dart pub global activate shader

# Compile all glsl files in our project
shader --use-remote --to-dart

# Discover all features
shader --help
```