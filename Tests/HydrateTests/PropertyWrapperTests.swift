//
//  File.swift
//  
//
//  Created by Lukas Simonson on 8/29/24.
//

import XCTest
@testable import Hydrate

final class PropertyWrapperTests: XCTest {
    func testHydratedPropertyWrapper() {
        let container = Container.shared
        container.registerSingleton(TestService())
        
        let viewModel = TestVM()
        let service1 = viewModel.service
        let service2 = viewModel.service
        
        XCTAssert(service1 === service2) // Testing that the service is resolved and cached
    }
}
