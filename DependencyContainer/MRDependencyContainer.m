//
//  MRServicesManager.m
//  Memrise
//
//  Created by Wojciech Chojnacki on 20/03/2016.
//  Copyright © 2016 Memrise. All rights reserved.
//

#import "MRDependencyContainer.h"
@import ObjectiveC;

@interface MRDependencyContainer ()
@property (nonatomic, strong) NSMutableDictionary *instances;
@property (nonatomic, strong) NSMutableDictionary *assemblers;
@property (nonatomic, strong) NSMutableOrderedSet<NSString *> *assemblersOrderedKeys;
@end

@implementation MRDependencyContainer

+ (instancetype)sharedContainer {
    static MRDependencyContainer *sharedContainer;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ sharedContainer = [[MRDependencyContainer alloc] init]; });
    return sharedContainer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _instances = [NSMutableDictionary dictionary];
        _assemblers = [NSMutableDictionary dictionary];
        _assemblersOrderedKeys = [NSMutableOrderedSet orderedSet];
    }
    return self;
}

#pragma mark - Setup

- (void)setup {
    _state = MRDependencyContainerStateInitializing;
    for (NSString *assemblerName in self.assemblersOrderedKeys) {
        id<MRDependencyAssembler> assembler = self.assemblers[assemblerName];
        id object = [assembler createInstanceWithContainer:self];
        self.instances[assemblerName] = object;
    }
    
    for (NSString *assemblerName in self.assemblersOrderedKeys) {
        id<MRDependencyAssembler> assembler = self.assemblers[assemblerName];
        id object = self.instances[assemblerName];
        [assembler setupInstance:object withContainer:self];
    }
    _state = MRDependencyContainerStateReady;
}

#pragma mark - Assemblers

- (void)registerAssembler:(nonnull id<MRDependencyAssembler>)assembler withName:(nonnull NSString *)name {
    NSParameterAssert(name); //make sure that name is not nil
    self.assemblers[name] = assembler;
    [self.assemblersOrderedKeys addObject:name];
}

- (BOOL)containsAsseblerWithName:(NSString *)name {
    NSParameterAssert(name); //make sure that name is not nil
    return self.assemblers[name] != nil;
}

#pragma mark - Resolving

- (BOOL)preResolveCheck {
    if(self.state == MRDependencyContainerStateUninitialized) {
        NSAssert(NO, @"Run setup before access services");
        return NO;
    }
    
    if(self.state == MRDependencyContainerStateError) {
        NSAssert(NO, @"Container is a Error state");
        return NO;
    }
    
    return YES;
}

- (id)resolveByClass:(nonnull Class)type {
    
    if(![self preResolveCheck]) {
        return nil;
    }
    
    NSArray *instances = self.instances.allValues;
    for (id item in instances) {
        if ([item isKindOfClass:type]) {
            return item;
        }
    }
    return nil;
}

- (id)resolveByProtocol:(nonnull Protocol *)type {
    [self preResolveCheck];
    NSArray *instances = self.instances.allValues;
    for (id item in instances) {
        if ([item conformsToProtocol:type]) {
            return item;
        }
    }
    return nil;
}



@end


@interface MRDefaultDependencyAssembler ()
@property (nullable, nonatomic, strong, readwrite) _Nonnull id(^createBlock)(MRDependencyContainer * _Nonnull);
@property (nonatomic, strong) Class type;
@end

@implementation MRDefaultDependencyAssembler

+ (nonnull instancetype)createWithType:(nonnull Class)type andBlock:(nonnull _Nonnull id (^)(MRDependencyContainer * _Nonnull container))createBlock {
    MRDefaultDependencyAssembler *assembler = [[MRDefaultDependencyAssembler alloc] init];
    assembler.createBlock = createBlock;
    assembler.type = type;
    return assembler;
}

- (id)createInstanceWithContainer:(MRDependencyContainer *)container {
    return self.createBlock(container);
}

- (void)setupInstance:(nonnull id)instance withContainer:(nonnull MRDependencyContainer *)container {
}
@end