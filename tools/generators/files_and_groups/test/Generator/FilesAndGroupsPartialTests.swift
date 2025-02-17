import CustomDump
import Foundation
import PBXProj
import XCTest

@testable import files_and_groups

class FilesAndGroupsPartialTests: XCTestCase {
    func test() {
        // Arrange

        let elementsPartial = #"""
		element /* path */ = {ELEMENT};

"""#

        // The tabs for indenting are intentional
        let expectedFilesAndGroupsPartial = #"""
		element /* path */ = {ELEMENT};
	};
	rootObject = 000000000000000000000001 /* Project object */;
}

"""#

        // Act

        let filesAndGroupsPartial = Generator.filesAndGroupsPartial(
            elementsPartial: elementsPartial
        )

        // Assert

        XCTAssertNoDifference(
			filesAndGroupsPartial,
			expectedFilesAndGroupsPartial
		)
    }
}
