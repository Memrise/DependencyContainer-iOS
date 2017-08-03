//
//  DependencyContainer.swift
//  DependencyContainer
//
//  Created by Wojciech Chojnacki on 12/07/2017.
//  Copyright © 2017 Memrise. All rights reserved.
//

import Foundation

@objc public enum DependencyContainerState: Int {
    case uninitialized = 0
    case initializing
    case ready
    case error //not supported
};

/**:
 
 */
@objc open class DependencyContainer: NSObject {
    private var legacyAssemblers: [LegacyDependencyAssembler] = []
    private var assemblers: [DependencyAssembler] = []
    private var resolvers: [Resolver] = []
    /**
     Current container state
    */
    @objc public private(set) var state: DependencyContainerState = .uninitialized
    
    private var resolveFunction: ((Any.Type) -> AnyObject?)?
    
    
    /**
        Initialize Container and create an object (from registered assemblers)
     
       In the first step singletone objects are created, then all newly created objects are setup by calling
       `DependencyAssembler::setup:`.
     */
    @objc public func setup() {
        state = .initializing
        resolvers = []
        var legacyInstances: [(Resolver, LegacyDependencyAssembler)] = []
        var instances: [(Resolver, DependencyAssembler)] = []
        
        resolveFunction = {
            for (resolver, _) in legacyInstances {
                if resolver.isAMatch(type: $0) {
                    return resolver.resolve()
                }
            }
            
            for (resolver, _) in instances {
                if resolver.isAMatch(type: $0) {
                    return resolver.resolve()
                }
            }
            
            return nil
        }
        
        for assembler in legacyAssemblers {
            let object = assembler.createInstance(with: self)
            let resolver = DefaultResolver(value: object, type:assembler.type)
            legacyInstances.append((resolver, assembler))
        }
        
        for assembler in assemblers {
            let object = assembler.createInstance(with: self)
            let resolver = DefaultResolver(value: object, type:assembler.type)
            instances.append((resolver, assembler))
        }
        
        for instanceTuple in legacyInstances {
            instanceTuple.1.setupInstance(instanceTuple.0.resolve(), with: self)
            resolvers.append(instanceTuple.0)
        }
        
        for instanceTuple in instances {
            instanceTuple.1.setupInstance(instanceTuple.0.resolve(), with: self)
            resolvers.append(instanceTuple.0)
        }

        resolveFunction = {
            for resolver in self.resolvers {
                if resolver.isAMatch(type: $0) {
                    return resolver.resolve()
                }
            }
            return nil
        }
        
        state = .ready
    }
    
    /**
     Register an assembler (class that defines how to create and setup an object in container)
     
     
       - parameters:
            - assembler assembler
     */
    public func register(_ assembler:LegacyDependencyAssembler) {
        legacyAssemblers.append(assembler)
    }
    
    public func register(_ assembler:DependencyAssembler) {
        assemblers.append(assembler)
    }
    
    @available(*, deprecated)
    public func register(_ assembler:LegacyDependencyAssembler, withName: String) {
        legacyAssemblers.append(assembler)
    }
    /**
       Search in the container for objects with class type. If there are more that one result - a first one is returned.
     
       - parameters:
        - by object type
     
       - returns:
        an object or nil if a dependency not found
     */
    public func resolve(by type: Any.Type) -> AnyObject? {
        guard preResolveCheck() else {
            return nil
        }
        
        return resolveFunction?(type)        
    }

    @objc public func resolve(byClass: AnyClass) -> AnyObject? {
        guard preResolveCheck() else {
            return nil
        }
        
        return resolve(by: byClass)
    }
    
    
    public func resolve<T: AnyObject>(type: T.Type) -> T? {
        guard preResolveCheck() else {
            return nil
        }
        
        return resolve(by: type) as? T
    }
    
    
    public func resolve<T: AnyObject>() -> T? {
        return resolve(by: T.self) as? T
    }
    
    private func preResolveCheck() -> Bool {
        switch state {
        case .uninitialized:
            assertionFailure("DependencyContainer: Run setup before access services")
            return false
        case .error:
            assertionFailure("DependencyContainer: Container is an error state")
            return false
        default:
            return true
        }
    }
}


protocol Resolver {
    func isAMatch(type: Any.Type) -> Bool
    func resolve() -> AnyObject
}

struct DefaultResolver: Resolver {
    let value: AnyObject
    let type: Any.Type
    
    func isAMatch(type clazz: Any.Type) -> Bool {
        if let c = clazz as? AnyClass {
            if value.isKind(of: c) {
                return true
            }
        }
        
        if type == clazz {
            return true
        }
        
        return false
    }
    
    func resolve() -> AnyObject {
        return value
    }
}
