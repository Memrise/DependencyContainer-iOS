//
//  MRDependencyContainerTests.swift
//  Memrise
//
//  Created by Wojciech Chojnacki on 26/06/2016.
//  Copyright © 2016 Memrise. All rights reserved.
//

import XCTest

@objc protocol MRDependencyContainerTestsTestServiceProtocol {
    
}

class Test0AService : MRDependencyContainerTestsTestServiceProtocol {
}

class Test0BService : Test0AService {
}

class Test0AServiceTwoStepAssebler : NSObject, MRDependencyAssembler {
    var createdInstanceSpy:Bool = false,
    setupInstanceSpy:Bool = false
    func type() -> AnyClass {
        return Test0AService.self
    }
    
    func createInstanceWithContainer(container: MRDependencyContainer) -> AnyObject {
        createdInstanceSpy = true
        return Test0AService()
    }
    
    func setupInstance(instance: AnyObject, withContainer container: MRDependencyContainer) {
        setupInstanceSpy = true
    }
}


class MRDependencyContainerTests: XCTestCase {
    
    func test_register() {
        let container = MRDependencyContainer()
        
        let s = MRDefaultDependencyAssembler.createWithType(Test0AService.self, andBlock:{ (container) -> AnyObject in
            XCTAssertEqual(container.state, MRDependencyContainerState.Initializing)
            return Test0AService()
        })
        container.registerAssembler(s,withName:"testService")
        
        XCTAssertTrue(container.containsAsseblerWithName("testService"))
    }
    
    func test_setup_states() {
        let container = MRDependencyContainer()
        
        let s = MRDefaultDependencyAssembler.createWithType(Test0AService.self, andBlock:{ (container) -> AnyObject in
            XCTAssertEqual(container.state, MRDependencyContainerState.Initializing)
            return Test0AService()
        })
        container.registerAssembler(s,withName:"testService")
        
        XCTAssertEqual(container.state, MRDependencyContainerState.Uninitialized)
        container.setup()
        XCTAssertEqual(container.state, MRDependencyContainerState.Ready)
    }
    
    
    func test_setup() {
        let container = MRDependencyContainer()
        
        var spy:Bool = false
        let s = MRDefaultDependencyAssembler.createWithType(Test0AService.self, andBlock:{ (container) -> AnyObject in
            spy = true
            return Test0AService()
        })
        container.registerAssembler(s,withName:"testService")
        
        XCTAssertEqual(container.state, MRDependencyContainerState.Uninitialized)
        container.setup()
        XCTAssertEqual(container.state, MRDependencyContainerState.Ready)
        XCTAssertTrue(spy)
    }
    
    func test_setup_twoStepInitialization() {
        let container = MRDependencyContainer()
        
        let s = Test0AServiceTwoStepAssebler()
        
        container.registerAssembler(s,withName:"testService")
        
        container.setup()
        XCTAssertTrue(s.createdInstanceSpy)
        XCTAssertTrue(s.setupInstanceSpy)
    }
    
    
    
    func test_resolve_basic() {
        let container = MRDependencyContainer()
        
        let s = MRDefaultDependencyAssembler.createWithType(Test0BService.self, andBlock:{ (manager) -> AnyObject in
            return Test0BService()
        })
        container.registerAssembler(s,withName:"testService")
        
        container.setup()
        
        let res1 = container.resolveByClass(Test0AService)
        XCTAssertNotNil(res1)
        
        let res2 = container.resolveByClass(Test0BService)
        XCTAssertNotNil(res2)
        
        let res3 = container.resolveByProtocol(MRDependencyContainerTestsTestServiceProtocol)
        XCTAssertNotNil(res3)
    }
    
    func test_resolve_bySubclas() {
        let container = MRDependencyContainer()
        
        let s = MRDefaultDependencyAssembler.createWithType(Test0BService.self, andBlock:{ (manager) -> AnyObject in
            return Test0BService()
        })
        container.registerAssembler(s,withName:"testService")
        
        container.setup()
        
        let res1 = container.resolveByClass(Test0BService)
        XCTAssertNotNil(res1)

    }
    
    func test_resolve_byProtocol() {
        let container = MRDependencyContainer()
        
        let s = MRDefaultDependencyAssembler.createWithType(Test0BService.self, andBlock:{ (manager) -> AnyObject in
            return Test0BService()
        })
        container.registerAssembler(s,withName:"testService")
        
        container.setup()
        
        let res1 = container.resolveByProtocol(MRDependencyContainerTestsTestServiceProtocol)
        XCTAssertNotNil(res1)
        
        let res2 = container.resolveByProtocol(UIApplicationDelegate)
        XCTAssertNil(res2)
    }
    
    func test_resolve_unknow() {
        let container = MRDependencyContainer()
        
        let s = MRDefaultDependencyAssembler.createWithType(Test0BService.self, andBlock:{ (manager) -> AnyObject in
            return Test0BService()
        })
        container.registerAssembler(s,withName:"testService")
        
        container.setup()
        
        let res1 = container.resolveByClass(MRDependencyContainerTests)
        XCTAssertNil(res1)
    }
    
    func test_resolve_container_before_initialization() {
        let container = MRDependencyContainer()
        
        let s = MRDefaultDependencyAssembler.createWithType(Test0BService.self, andBlock:{ (manager) -> AnyObject in
            return Test0BService()
        })
        container.registerAssembler(s,withName:"testService")
        
        XCTAssertEqual(container.state, MRDependencyContainerState.Uninitialized)
        let res1 = container.resolveByClass(Test0BService)
        XCTAssertNil(res1)
    }
    
    func test_sharedContainer() {
        let container = MRDependencyContainer.sharedContainer()
        XCTAssertNotNil(container)
    }
    
}
