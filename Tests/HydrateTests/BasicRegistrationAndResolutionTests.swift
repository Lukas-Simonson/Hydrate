//
//  BasicRegistrationAndResolutionTests.swift
//  
//
//  Created by Lukas Simonson on 8/29/24.
//

import XCTest
@testable import Hydrate

final class BasicRegistrationAndResolutionTests: XCTestCase {
    func testBasicRegistrationAndResolution() {
        let container = Container()
        container.registerSingleton(TestService())
        
        let resolvedService = container.resolve(TestService.self)
        
        XCTAssertNotNil(resolvedService)
    }

    func testSingletonInstanceReused() {
        let container = Container()
        container.registerSingleton(TestService())
        
        let service1 = container.resolve(TestService.self)
        let service2 = container.resolve(TestService.self)
        
        XCTAssert(service1 === service2) // Testing that both references point to the same instance
    }

    func testFactoryCreatesNewInstances() {
        let container = Container()
        container.register(factory: { _ in TestService() })
        
        let service1 = container.resolve(TestService.self)
        let service2 = container.resolve(TestService.self)
        
        XCTAssert(service1 !== service2) // Testing that each resolve produces a new instance
    }
}
