//
//  DefaultDependencyAssembler.swift
//  DependencyContainer
//
//  Created by Wojciech Chojnacki on 24/07/2017.
//  Copyright © 2017 Memrise. All rights reserved.
//

import Foundation

@objc open class DefaultLegacyDependencyAssembler: NSObject, LegacyDependencyAssembler {
    public let type: AnyClass
    let createBlock: (_ container: DependencyContainer) -> AnyObject
    
    public init(type: AnyClass, createBlock:@escaping (_ container: DependencyContainer) -> AnyObject) {
        self.type = type
        self.createBlock = createBlock
        super.init()
    }
    
    static public func create(withType: AnyClass, andBlock:@escaping (_ container: DependencyContainer) -> AnyObject) -> DefaultLegacyDependencyAssembler{
        return DefaultLegacyDependencyAssembler(type: withType, createBlock: andBlock)
    }
    
    public func createInstance(with container: DependencyContainer) -> AnyObject {
        return createBlock(container)
    }
    
    public func setupInstance(_ instance: AnyObject, with container: DependencyContainer) -> Void {
        //unused
    }
}


open class DefaultDependencyAssembler: DependencyAssembler {
    public let type: Any.Type
    let createBlock: (_ container: DependencyContainer) -> AnyObject
    
    public init<U: AnyObject>(type: Any.Type, createBlock:@escaping (_ container: DependencyContainer) -> U){
        self.type = type
        self.createBlock = createBlock
    }
    
    public func createInstance(with container: DependencyContainer) -> AnyObject {
        return createBlock(container)
    }
    
    public func setupInstance(_ instance: AnyObject, with container: DependencyContainer) -> Void {
        //unused
    }
}
