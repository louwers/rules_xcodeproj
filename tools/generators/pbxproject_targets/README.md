# `PBXProject.targets` `PBXProj` partials generator

The `pbxproject_targets` generator creates four+ files:

- A `PBXProj` partial containing the `PBXProject.attributes.TargetAttributes` property
- A `PBXProj` partial containing:
  - The `PBXProject.targets` property
  - Closes the `PBXProject` element
- A `PBXProj` partial containing the `PBXTargetDependency` and `PBXContainerItemProxy` elements
- A set of files, each detailing how a set of configured targets are consolidated together

## Inputs

The generator accepts the following command-line arguments (see
[`Arguments.swift`](src/Generator/Arguments.swift) and
[`PBXProjectTargets.swift`](src/PBXProjectTargets.swift) for more details):

- Positional `targets-output-path`
- Positional `target-attributes-output-path`
- Positional `targetdependencies-output-path`
- Option `--consolidation-map-output-paths <consolidation-map-output-path> ...`
- Option `--label-counts <label-count> ...`
- Option `--labels <label> ...`
- Option `--target-counts <target-count> ...`
- Option `--targets <target> ...`
- Option `--xcode-configuration-counts <xcode-configuration-count> ...`
- Option `--xcode-configurations <xcode-configuration> ...`
- Option `--product-types <product-types> ...`
- Option `--product-paths <product-path> ...`
- Option `--platforms <platform> ...`
- Option `--os-versions <os-version> ...`
- Option `--archs <arch> ...`
- Option `--dependency-counts <dependency-count> ...`
- Option `--dependencies <dependency> ...`
- Flag `--colorize`

Here is an example invocation:

```shell
$ pbxproject_targets \
    /tmp/pbxproj_partials/pbxproject_targets \
    /tmp/pbxproj_partials/pbxproject_target_attributes \
    /tmp/pbxproj_partials/pbxtargetdependencies \
    --consolidation-map-output-paths \
    /tmp/pbxproj_partials/consolidation_maps/0 \
    /tmp/pbxproj_partials/consolidation_maps/1 \
    --label-counts \
    2 \
    1 \
    --labels \
    //tools/generators/legacy:generator \
    //tools/generators/legacy/test:tests.__internal__.__test_bundle \
    //tools/generators/legacy:generator.library \
    --target-counts \
    1 \
    1 \
    1 \
    --targets \
    //tools/generators/legacy:generator applebin_macos-darwin_x86_64-dbg-STABLE-3 \
    //tools/generators/legacy/test:tests.__internal__.__test_bundle applebin_macos-darwin_x86_64-dbg-STABLE-3 \
    //tools/generators/legacy:generator.library macos-x86_64-min12.0-applebin_macos-darwin_x86_64-dbg-STABLE-1 \
    --xcode-configuration-counts \
    2 \
    1 \
    1 \
    --xcode-configurations \
    Debug \
    Release \
    Debug \
    Debug \
    --product-types \
    com.apple.product-type.tool \
    com.apple.product-type.bundle.unit-test \
    com.apple.product-type.library.static \
    --product-paths \
    bazel-out/applebin_macos-darwin_x86_64-dbg-STABLE-3/bin/tools/generators/legacy/generator \
    bazel-out/applebin_macos-darwin_x86_64-dbg-STABLE-3/bin/tools/generators/legacy/test/tests.__internal__.__test_bundle_archive-root/tests.xctest \
    bazel-out/macos-x86_64-min12.0-applebin_macos-darwin_x86_64-dbg-STABLE-1/bin/tools/generators/legacy/libgenerator.library.a \
    --platforms \
    macosx \
    macosx \
    macosx \
    --os-versions \
    12.0 \
    12.0 \
    12.0 \
    --archs \
    x86_64 \
    x86_64 \
    x86_64 \
    --dependency-counts \
    1 \
    3 \
    5 \
    --dependencies \
    //tools/generators/legacy:generator.library macos-x86_64-min12.0-applebin_macos-darwin_x86_64-dbg-STABLE-1 \
    //tools/generators/legacy:generator.library macos-x86_64-min12.0-applebin_macos-darwin_x86_64-dbg-STABLE-1 \
    //tools/generators/lib/GeneratorCommon:GeneratorCommon macos-x86_64-min12.0-applebin_macos-darwin_x86_64-dbg-STABLE-1 \
    @com_github_pointfreeco_swift_custom_dump//:CustomDump macos-x86_64-min12.0-applebin_macos-darwin_x86_64-dbg-STABLE-1 \
    //tools/generators/lib/GeneratorCommon:GeneratorCommon macos-x86_64-min12.0-applebin_macos-darwin_x86_64-dbg-STABLE-1 \
    @com_github_apple_swift_collections//:OrderedCollections macos-x86_64-min12.0-applebin_macos-darwin_x86_64-dbg-STABLE-1 \
    @com_github_kylef_pathkit//:PathKit macos-x86_64-min12.0-applebin_macos-darwin_x86_64-dbg-STABLE-1 \
    @com_github_michaeleisel_zippyjson//:ZippyJSON macos-x86_64-min12.0-applebin_macos-darwin_x86_64-dbg-STABLE-1 \
    @com_github_tuist_xcodeproj//:XcodeProj macos-x86_64-min12.0-applebin_macos-darwin_x86_64-dbg-STABLE-1
```

## Output

Here is an example output:

### `pbxproject_targets`

```

```

### `pbxproject_target_attributes`

```

```

### `pbxtargetdependencies`

```

```

### `consolidation_maps/0`

```

```

### `consolidation_maps/1`

```

```
