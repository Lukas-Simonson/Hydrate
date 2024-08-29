//
//  File.swift
//  
//
//  Created by Lukas Simonson on 8/29/24.
//

import XCTest
@testable import Hydrate

final class NamedRegistrationAndResolutionTests: XCTest {
    func testNamedRegistrationAndResolution() {
        let container = Container()
        container.registerSingleton(TestService(), named: "primary")
        container.registerSingleton(TestService(), named: "secondary")
        
        let primaryService = container.resolve(TestService.self, named: "primary")
        let secondaryService = container.resolve(TestService.self, named: "secondary")
        
        XCTAssertNotNil(primaryService)
        XCTAssertNotNil(secondaryService)
        XCTAssert(primaryService !== secondaryService)
    }
}
