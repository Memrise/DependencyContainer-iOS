//
//  DependencyContainerTests.swift
//  Memrise
//
//  Created by Wojciech Chojnacki on 26/06/2016.
//  Copyright © 2016 Memrise. All rights reserved.
//

import XCTest
import DependencyContainer

protocol DCTestServiceProtocol {

}

class Test0AService: DCTestServiceProtocol {
}

class Test0BService: Test0AService {
}

class Test0CService {
}

class Test0AServiceTwoStepAssebler: NSObject, LegacyDependencyAssembler {
    var createdInstanceSpy: Bool = false,
    setupInstanceSpy: Bool = false
    var type: AnyClass {
        return Test0AService.self
    }

    func createInstance(with container: DependencyContainer) -> AnyObject {
        createdInstanceSpy = true
        return Test0AService()
    }

    func setupInstance(_ instance: AnyObject, with container: DependencyContainer) {
        setupInstanceSpy = true
    }
}

class DependencyContainerTests: XCTestCase {

    func test_setup_states() {
        let container = DependencyContainer()

        let s = DefaultDependencyAssembler(type: Test0AService.self) { (container) -> Test0AService in
            XCTAssertEqual(container.state, DependencyContainerState.initializing)
            return Test0AService()
        }
        container.register(s)

        XCTAssertEqual(container.state, DependencyContainerState.uninitialized)
        container.setup()
        XCTAssertEqual(container.state, DependencyContainerState.ready)
    }

    func test_setup() {
        let container = DependencyContainer()

        var spy: Bool = false
        let s = DefaultDependencyAssembler(type: Test0AService.self) { (_) -> Test0AService in
            spy = true
            return Test0AService()
        }
        container.register(s)

        XCTAssertEqual(container.state, DependencyContainerState.uninitialized)
        container.setup()
        XCTAssertEqual(container.state, DependencyContainerState.ready)
        XCTAssertTrue(spy)
    }

    func test_setup_twoStepInitialization() {
        let container = DependencyContainer()

        let s = Test0AServiceTwoStepAssebler()

        container.register(s)

        container.setup()
        XCTAssertTrue(s.createdInstanceSpy)
        XCTAssertTrue(s.setupInstanceSpy)
    }

    func test_resolve_basic() {
        let container = DependencyContainer()

        let s = DefaultDependencyAssembler(type: Test0BService.self) { (_) -> Test0BService in
            return Test0BService()
        }

        container.register(s)

        container.setup()

        let res1: Test0BService? = container.resolve(type: Test0BService.self)

        XCTAssertNotNil(res1)
    }

    func test_resolve_bySubclas() {
        let container = DependencyContainer()

        let s = DefaultDependencyAssembler(type: Test0BService.self) { (_) -> Test0BService in
            return Test0BService()
        }
        container.register(s)

        container.setup()

        let res1 = container.resolve(by: Test0AService.self)
        XCTAssertNotNil(res1)

    }

    func test_resolve_byProtocol() {
        let container = DependencyContainer()

        let s = DefaultDependencyAssembler(type: DCTestServiceProtocol.self) { (_) -> Test0BService in
            return Test0BService()
        }
        container.register(s)

        container.setup()

        let res1 = container.resolve(by: DCTestServiceProtocol.self)
        XCTAssertNotNil(res1)

        let res2 = container.resolve(by: UIApplicationDelegate.self)
        XCTAssertNil(res2)

        let res3 = container.resolve(by: Test0BService.self)
        XCTAssertNotNil(res3)
    }

    func test_resolve_unknow_dependency() {
        let container = DependencyContainer()

        let s = DefaultDependencyAssembler(type: Test0BService.self) { (_) -> Test0BService in
            return Test0BService()
        }
        container.register(s)

        container.setup()

        let res1 = container.resolve(by: DependencyContainerTests.self)
        XCTAssertNil(res1)
    }

    func test_resolve_shortest_form() {
        let container = DependencyContainer()

        let s = DefaultDependencyAssembler(type: Test0AService.self) { (_) -> Test0AService in
            return Test0AService()
        }
        container.register(s)

        container.setup()

        let res1 = container.resolve() as Test0AService?
        XCTAssertNotNil(res1)

        let res2 = container.resolve() as Test0BService?
        XCTAssertNil(res2)
    }

    func test_assembler_resolve_dependencies() {
        let container = DependencyContainer()

        let s1 = DefaultDependencyAssembler(type: Test0AService.self) { (_) -> Test0AService in
            return Test0AService()
        }
        container.register(s1)

        var resolvedInAssembler = false

        let s2 = DefaultDependencyAssembler(type: Test0CService.self) { (manager) -> Test0CService in
            let service: Test0AService? = manager.resolve()

            resolvedInAssembler = service != nil

            return Test0CService()
        }
        container.register(s2)

        container.setup()

        XCTAssertTrue(resolvedInAssembler)

    }

}
