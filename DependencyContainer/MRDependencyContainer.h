//
//  MRServicesManager.h
//  Memrise
//
//  Created by Wojciech Chojnacki on 20/03/2016.
//  Copyright © 2016 Memrise. All rights reserved.
//

@import Foundation;

@protocol MRDependencyAssembler;

typedef NS_ENUM(NSUInteger, MRDependencyContainerState) {
    MRDependencyContainerStateUninitialized,
    MRDependencyContainerStateInitializing,
    MRDependencyContainerStateReady,
    MRDependencyContainerStateError //not supported
};

/**
 *  Dependency container - one place to rule all services/managers/singletons
 *
 *  Usage
 *   TODO
 *
 *  States
 *   During a setup phase, container goes through Unitialized->Initializing->Ready states.
 *   You are allow to resolve object only in Ready state.
 *   You can resolve object in Initializing state only from assemblers.
 *
 *  Limitations
 *  - circular dependencies not supported per se, check docs for MRDependencyAssembler:setupInstance:withContainer
 *  - object in container has only one instance and is created on setup. (it's like singleton)
 *  - order in witch we register assemblers is important.
 */
@interface MRDependencyContainer : NSObject
@property (readonly, nonatomic) MRDependencyContainerState state;

+ (nonnull instancetype)sharedContainer;

/**
 *    Initialize Container and create an object (from registered assemblers)
 *
 *  In the first step singletone objects are created, then all newly created objects are setup by calling
 *  `- (void)setupInstance:(nonnull id)instance withContainer:(nonnull MRDependencyContainer *)container;` on they assembler.
 */
- (void)setup;

/**
 *  Register an assembler (class that defines how to create and setup an object in container)
 *
 *
 *  @param assembler assembler
 *  @param name      unique identifier for assembler
 */
- (void)registerAssembler:(nonnull id<MRDependencyAssembler>)assembler withName:(nonnull NSString *)name;


- (BOOL)containsAsseblerWithName:(nonnull NSString *)name;

/**
 *  Search in the container for objects with class type. If there are more that one result - a first one is returned.
 *
 *  @param type object type
 *
 *  @return an object or nil if not found
 */
- (nullable id)resolveByClass:(nonnull Class)type;

/**
 *  Search in the container for objects that confirms to protocol. If there are more results - a first one is returned.
 *
 *  @param type requested protocol
 *
 *  @return an object or nil if not found
 */
- (nullable id)resolveByProtocol:(nonnull Protocol *)type;
@end

#pragma mark - Assembler
/**
 *  Assembler - an object that defines a method to create and setup a class instance.
 *
 */
@protocol MRDependencyAssembler
/**
 *  The type created by assembler
 *
 *  @return class type
 */
- (nonnull Class)type;
/**
 *  Method called when dependency container wants to create an object.
 *  Object initialization may involve resolving dependencies to other objects
 *
 *  @param container reference to dependency container
 *
 *  @return object instance
 */
- (nonnull id)createInstanceWithContainer:(nonnull MRDependencyContainer *)container;
/**
 *  Method called after creating all object in the container.
 *  One of an example where this method may be helpful is setting object dependencies through properties. This should
 *  solve cases where we have modules with circular dependencies.
 *
 *
 *  @param instance  object instance
 *  @param container dependency container
 */
- (void)setupInstance:(nonnull id)instance withContainer:(nonnull MRDependencyContainer *)container;
@end


#pragma mark - MRDefaultDependencyAssembler
/**
 *  Convinient default assembler implementation to support simple "by construction" object initialization.
 *
 */
@interface MRDefaultDependencyAssembler : NSObject <MRDependencyAssembler>
@property (nullable, nonatomic, strong, readonly) _Nonnull id(^createBlock)(MRDependencyContainer * _Nonnull container);
+ (nonnull instancetype)createWithType:(nonnull Class)type andBlock:(nonnull _Nonnull id (^)(MRDependencyContainer * _Nonnull container))createBlock ;
@end
