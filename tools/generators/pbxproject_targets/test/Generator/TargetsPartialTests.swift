import CustomDump
import XCTest

@testable import pbxproject_targets

class TargetsPartialTests: XCTestCase {
    func test() {
        // Arrange

        // The tabs for indenting are intentional
        let expectedTargetsPartial = #"""

"""#

        // Act

//        let targetsPartial = Generator.targetsPartial(
//        )
        let targetsPartial = ""

        // Assert

        XCTAssertNoDifference(
			targetsPartial,
			expectedTargetsPartial
		)
    }
}
