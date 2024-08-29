//
//  File.swift
//  
//
//  Created by Lukas Simonson on 8/29/24.
//

import Hydrate

internal final class TestService {
    
}

internal final class TestVM {
    @Hydrated var service: TestService
}

internal struct TestCustomProvider: Provider {
    func provide(with resolver: Resolver) -> TestService {
        return TestService()
    }
}
