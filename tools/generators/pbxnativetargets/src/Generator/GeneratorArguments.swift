import ArgumentParser
import Foundation

extension Generator {
    struct Arguments: ParsableArguments {
        @Argument(
            help: """
Path to where the 'pbxnativetargets' 'PBXProj' partial should be written.
""",
            transform: { URL(fileURLWithPath: $0, isDirectory: false) }
        )
        var targetsOutputPath: URL

        @Argument(
            help: """
Path to where the 'PBXBuildFile' map should be written.
""",
            transform: { URL(fileURLWithPath: $0, isDirectory: false) }
        )
        var buildfileMapOutputPath: URL

        @Argument(
            help: """
Path to the directory where automatic `.xcscheme` files should be written.
""",
            transform: { URL(fileURLWithPath: $0, isDirectory: true) }
        )
        var xcshemesOutputDirectory: URL

        @Argument(
            help: "Path to the consolidation map.",
            transform: { URL(fileURLWithPath: $0, isDirectory: false) }
        )
        var consolidationMap: URL

        @Argument(
            help: "Path to the consolidation map."
        )
        var hostedTargets: [String]

        @OptionGroup var targetsArguments: TargetsArguments

        mutating func validate() throws {
            guard hostedTargets.count.isMultiple(of: 2) else {
                throw ValidationError("""
<hosted-targets> (\(hostedTargets.count) elements) must be <host-target> and \
<hosted-target> pairs.
""")
            }

            // FIXME: Verify that hostedTargets are valid (reference correct targets?)
        }
    }
}
