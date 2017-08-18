//
//  DependencyAssembler.swift
//  DependencyContainer
//
//  Created by Wojciech Chojnacki on 24/07/2017.
//  Copyright © 2017 Memrise. All rights reserved.
//

import Foundation

/**
   Assembler - an object that defines methods to create and setup a class instance.
 */
@objc public protocol LegacyDependencyAssembler: class {
    /**
       The type created by assembler
     
       - returns:
       class type
     */
    var type: AnyClass {get}

    /**
       Method called when dependency container wants to create an object.
       Object initialization may involve resolving dependencies to other objects
     
       - parameters:
            - container container reference to dependency container
     
       - returns:
       object instance
     */
    func createInstance(with container: DependencyContainer) -> AnyObject

    /**
        Method called after creating all object in the container.
        One of an example where this method may be helpful is setting object dependencies through properties. 
        This should solve cases where we have modules with circular dependencies.
     
        - parameters:
            - instance  object created by this assembled
            - container dependency container
      */
    func setupInstance(_ instance: AnyObject, with container: DependencyContainer)
}

public protocol DependencyAssembler: class {
    var type: Any.Type {get}

    func createInstance(with container: DependencyContainer) -> AnyObject

    func setupInstance(_ instance: AnyObject, with container: DependencyContainer)
}
