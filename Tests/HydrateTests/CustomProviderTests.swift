//
//  File.swift
//  
//
//  Created by Lukas Simonson on 8/29/24.
//

import XCTest
@testable import Hydrate

class CustomProviderTests: XCTest {
    func testCustomProvider() {
        let container = Container()
        container.registerProvider(TestCustomProvider(), named: "custom")
        
        let service = container.resolve(TestService.self, named: "custom")
        
        XCTAssertNotNil(service)
    }
}
