# crystal-imgui-backends

This shard makes it easy to use ImGui backends from Crystal.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
    imgui-backends:
      github: mattrberry/crystal-imgui-backends
      tag: v1.86 # select your version here by git tag
    imgui: # chances are you want to include imgui as well
      github: oprypin/crystal-imgui
      tag: v1.86 # should match version used above
   ```

2. Run `shards install`

## Usage

```crystal
require "imgui-backends"
require "imgui-backends/lib"

# ImGui::<backend name>::method()
ImGui::OpenGL3.new_frame
ImGui::SDL2.new_frame(@window)
```

All backends are under a module sharing their name (like "SDL2" or :OpenGL3"), which is in turn under the module "ImGui".

For a minimal example, run the following:

```bash
shards install
make
crystal examples/imgui_impl_opengl3.cr
```

For a concrete example using this shard, see https://github.com/mattrberry/crab. The `make shard` is run as a postinstall step when this shard is installed, so ImGui links are generated automatically.

## Development

Development is currently a manual process, and new backends are added as necessary. If you would like to use a backend or method that's not currently supported, you're welcome to add it following the convention in the src/ dir. If you add a new backend, it would be nice to create an example using that backend under examples/ as well.

## Contributing

1. Fork it (<https://github.com/mattrberry/crystal-imgui-backends/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Matthew Berry](https://github.com/mattrberry) - creator and maintainer
