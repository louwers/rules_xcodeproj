import ArgumentParser
import Foundation

extension Generator {
    struct Arguments: ParsableArguments {
        @Argument(
            help: """
Path to where the 'pbxproject_targets' 'PBXProj' partial should be written.
""",
            transform: { URL(fileURLWithPath: $0, isDirectory: false) }
        )
        var targetsOutputPath: URL

        @Argument(
            help: """
Path to where the 'pbxproject_target_attributes' 'PBXProj' partial should be \
written.
""",
            transform: { URL(fileURLWithPath: $0, isDirectory: false) }
        )
        var targetAttributesOutputPath: URL

        @Argument(
            help: """
Path to where the 'pbxtargetdependencies' 'PBXProj' partial should be written.
""",
            transform: { URL(fileURLWithPath: $0, isDirectory: false) }
        )
        var targetdependenciesOutputPath: URL

        @OptionGroup var consolidationMapsArguments: ConsolidationMapsArguments
    }
}
