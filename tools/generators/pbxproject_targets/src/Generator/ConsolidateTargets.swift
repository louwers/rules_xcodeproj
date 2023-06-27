import GeneratorCommon
import PBXProj

struct ConsolidatedTarget: Equatable, Hashable {
    var ids: Set<TargetID>
}

extension ConsolidatedTarget {
    init<TargetIDs: Sequence>(
        _ ids: TargetIDs
    ) where TargetIDs.Element == TargetID {
        self.ids = Set(ids)
    }
}

extension ConsolidatedTarget: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: TargetID...) {
        self.init(elements)
    }
}

extension Generator {

    /// Attempts to consolidate targets that differ only by configuration.
    ///
    /// - See: `ConsolidatedTarget`.
    ///
    /// - Parameters:
    ///   - targets: All the targets.
    ///   - logger: A `Logger` to output warnings to when certain configuration
    ///     prevents a consolidation.
    static func consolidateTargets(
        _ targets: [Target],
        logger: Logger
    ) throws -> Set<ConsolidatedTarget> {
        // First pass
        var consolidatable: [ConsolidatableKey: Set<TargetID>] = [:]
        for target in targets {
            consolidatable[.init(target: target), default: []].insert(target.id)
        }

        let targets = Dictionary(
            uniqueKeysWithValues: targets.map { ($0.id, $0) }
        )

        // Filter out multiple targets of the same platform name
        // TODO: Eventually we should probably support this, for Universal macOS
        //   binaries. Xcode doesn't respect the `arch` condition for product
        //   directory related build settings, so it's non-trivial to support.
        var consolidateGroups: [Set<TargetID>] = []
        for ids in consolidatable.values {
            // We group by `XcodeConfigurationAndPlatform` to allow matching
            // of the same configured targets, but with different Xcode
            // configuration names or platform names
            var configurations: [
                XcodeConfigurationAndPlatform:
                    [ConsolidationBucketDistinguisher: TargetID]
            ] = [:]
            for id in ids {
                let target = targets[id]!
                let platform = target.platform
                let configuration = ConsolidationBucketDistinguisher(
                    platform: platform,
                    osVersion: target.osVersion,
                    arch: target.arch,
                    id: target.id
                )
                for xcodeConfiguration in target.xcodeConfigurations {
                    let distinguisher = XcodeConfigurationAndPlatform(
                        xcodeConfiguration: xcodeConfiguration,
                        platform: platform
                    )
                    configurations[distinguisher, default: [:]][configuration] =
                        id
                }
            }

            var buckets: [Int: Set<TargetID>] = [:]
            for ids in configurations.values {
                // TODO: Handle situations where a unique configurations messes
                //   up the sorting (e.g. single different minimum os
                //   configuration where the rest of the targets are pairs of
                //   minimum os versions differing by environment)
                let sortedIDs = ids
                    .sorted { $0.key < $1.key }
                    .map(\.value)
                for (idx, id) in sortedIDs.enumerated() {
                    buckets[idx, default: []].insert(id)
                }
            }

            for ids in buckets.values {
                consolidateGroups.append(ids)
            }
        }

        // Build up mappings
        var targetIDMapping: [TargetID: ConsolidatedTarget] = [:]
        var consolidatedTargets: Set<ConsolidatedTarget> = []
        for ids in consolidateGroups {
            let consolidatedTarget = ConsolidatedTarget(ids)
            consolidatedTargets.insert(consolidatedTarget)
            for id in ids {
                targetIDMapping[id] = consolidatedTarget
            }
        }

        // Calculate dependencies
        func resolveDependency(
            _ depID: TargetID,
            for id: TargetID
        ) throws -> ConsolidatedTarget {
            guard let dependencyKey = targetIDMapping[depID] else {
                throw PreconditionError(message: """
Target "\(id)" dependency on "\(depID)" not found in \
`consolidateTargets().targetIDMapping`
""")
            }
            return dependencyKey
        }

        var depsMap: [TargetID: Set<ConsolidatedTarget>] = [:]
        var rdepsMap: [ConsolidatedTarget: Set<ConsolidatedTarget>] = [:]
        func updateDependencies(
            for id: TargetID,
            to consolidatedTarget: ConsolidatedTarget
        ) throws {
            guard let target = targets[id] else {
                throw PreconditionError(message: """
Target "\(id)" not found in `consolidateTargets().targets`
""")
            }

            let dependencies: Set<ConsolidatedTarget> = try .init(
                target.dependencies.map { depID in
                    return try resolveDependency(depID, for: id)
                }
            )

            depsMap[id] = dependencies
            for dependencyKey in dependencies {
                rdepsMap[dependencyKey, default: []].insert(consolidatedTarget)
            }
        }

        func updateDependencies(
            for consolidatedTarget: ConsolidatedTarget
        ) throws {
            try consolidatedTarget.ids.forEach { id in
                try updateDependencies(for: id, to: consolidatedTarget)
            }
        }

        try consolidatedTargets.forEach { try updateDependencies(for: $0) }

        var consolidatedTargetsToEvaluate =
        consolidatedTargets.filter { $0.ids.count > 1 }

        // Account for conditional dependencies
        func deconsolidateTarget(
            _ consolidatedTarget: ConsolidatedTarget,
            into targetIDsForKeys: [Set<TargetID>]
        ) throws {
            consolidatedTargets.remove(consolidatedTarget)
            for id in consolidatedTarget.ids {
                targetIDMapping.removeValue(forKey: id)
            }

            for targetIDs in targetIDsForKeys {
                let newConsolidatedTarget = ConsolidatedTarget(targetIDs)
                consolidatedTargets.insert(newConsolidatedTarget)
                for id in targetIDs {
                    targetIDMapping[id] = newConsolidatedTarget
                }
            }

            // Reevaluate dependent targets
            if let rdeps = rdepsMap.removeValue(forKey: consolidatedTarget) {
                for rdep in rdeps {
                    guard consolidatedTargets.contains(rdep) else {
                        // If rdep has already been deconsolidated, we don't
                        // need to do anything with it. And actually doing
                        // anything can lead to errors.
                        continue
                    }
                    try updateDependencies(for: rdep)
                    consolidatedTargetsToEvaluate.insert(rdep)
                }
            }
        }

        while !consolidatedTargetsToEvaluate.isEmpty {
            let consolidatedTarget = consolidatedTargetsToEvaluate.popFirst()!
            var depsGrouping: [Set<ConsolidatedTarget>: Set<TargetID>] = [:]
            for id in consolidatedTarget.ids {
                depsGrouping[depsMap[id] ?? [], default: []].insert(id)
            }

            guard depsGrouping.count == 1 else {
                let depGroupingStr = depsGrouping.values
                    .map { "\($0.sorted())" }
                    .sorted()
                    .joined(separator: ", ")
                logger.logWarning("""
Was unable to consolidate target groupings "\(depGroupingStr)" since they have \
conditional dependencies (e.g. `deps`, `test_host`, `watch_application`, etc.)
""")
                try deconsolidateTarget(
                    consolidatedTarget,
                    into: Array(depsGrouping.values)
                )
                continue
            }
        }

        return consolidatedTargets
    }
}

// MARK: - Computation

/// If multiple targets have the same `ConsolidatableKey`, they can
/// potentially be consolidated. "Potentially", since there are some
/// disqualifying properties that require further inspection (e.g conditional
/// dependencies).
private struct ConsolidatableKey: Equatable, Hashable {
    let label: String
    let productType: PBXProductType

    /// Used to prevent watchOS from consolidating with other platforms. Xcode
    /// gets confused when a watchOS App target depends on a consolidated
    /// iOS/watchOS dependency, so we just don't let it get into that situation.
    let isWatchOS: Bool
}

extension ConsolidatableKey {
    init(target: Target) {
        label = target.label
        productType = target.productType
        isWatchOS = target.platform.os == .watchOS
    }
}

private struct XcodeConfigurationAndPlatform: Equatable, Hashable {
    let xcodeConfiguration: String
    let platform: Platform
}

private struct ConsolidationBucketDistinguisher: Equatable, Hashable {
    let platform: Platform
    let osVersion: SemanticVersion
    let arch: String
    let id: TargetID
}

extension ConsolidationBucketDistinguisher: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        return (lhs.platform, lhs.osVersion, lhs.arch, lhs.id.rawValue) <
            (rhs.platform, rhs.osVersion, rhs.arch, rhs.id.rawValue)
    }
}
