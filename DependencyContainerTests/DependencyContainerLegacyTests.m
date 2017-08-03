//
//  DependencyContainerLegacyTests.m
//  DependencyContainer
//
//  Created by Wojciech Chojnacki on 02/08/2017.
//  Copyright © 2017 Memrise. All rights reserved.
//

#import <XCTest/XCTest.h>
@import DependencyContainer;

@protocol DependencyContainerTestsTestServiceProtocol
@end

@interface Test1AService: NSObject <DependencyContainerTestsTestServiceProtocol>

@end

@implementation Test1AService


@end

@interface Test1BService: Test1AService

@end

@implementation Test1BService

@end


@interface Test1AServiceTwoStepAssebler : NSObject <LegacyDependencyAssembler>
@property (nonatomic) BOOL createdInstanceSpy;
@property (nonatomic) BOOL setupInstanceSpy;
@end

@implementation Test1AServiceTwoStepAssebler

- (Class)type {
    return Test1AService.self;
}

- (id _Nonnull)createInstanceWith:(DependencyContainer * _Nonnull)container {
    self.createdInstanceSpy = YES;
    return [[Test1AService alloc] init];
}

- (void)setupInstance:(id _Nonnull)instance with:(DependencyContainer * _Nonnull)container {
    self.setupInstanceSpy = YES;
}

@end

@interface DependencyContainerLegacyTests : XCTestCase
@property (nonatomic, strong) DependencyContainer *container;
@end

@implementation DependencyContainerLegacyTests

- (void)setUp {
    self.container = [[DependencyContainer alloc] init];
}

- (void)test_setup_states {
    id<LegacyDependencyAssembler> assembler = [DefaultLegacyDependencyAssembler createWithType:[Test1AService class] andBlock:^id _Nonnull(DependencyContainer * _Nonnull container) {
        XCTAssertEqual(container.state, DependencyContainerStateInitializing);
        return [[Test1AService alloc] init];
    }];
    [self.container register:assembler];

    XCTAssertEqual(self.container.state, DependencyContainerStateUninitialized);
    [self.container setup];
    XCTAssertEqual(self.container.state, DependencyContainerStateReady);
}


- (void)test_setup_twoStepInitialization {
    Test1AServiceTwoStepAssebler *assembler = [[Test1AServiceTwoStepAssebler alloc] init];
    
    [self.container register:assembler];
    
    [self.container setup];
    XCTAssertTrue(assembler.createdInstanceSpy);
    XCTAssertTrue(assembler.setupInstanceSpy);
}


- (void)test_resolve_basic {
    id<LegacyDependencyAssembler> assembler = [DefaultLegacyDependencyAssembler createWithType:[Test1AService class] andBlock:^id _Nonnull(DependencyContainer * _Nonnull container) {
        return [[Test1AService alloc] init];
    }];
    [self.container register:assembler];
    [self.container setup];
    
    Test1BService *res1 = [self.container resolveByClass:[Test1AService class]];
    XCTAssertNotNil(res1);    
}

- (void)test_resolve_bySubclas {
    id<LegacyDependencyAssembler> assembler = [DefaultLegacyDependencyAssembler createWithType:[Test1AService class] andBlock:^id _Nonnull(DependencyContainer * _Nonnull container) {
        return [[Test1BService alloc] init];
    }];
    [self.container register:assembler];
    [self.container setup];
    
    Test1BService *res1 = [self.container resolveByClass:[Test1AService class]];
    XCTAssertNotNil(res1);
}

- (void)test_resolve_unknow_dependency {
    id<LegacyDependencyAssembler> assembler = [DefaultLegacyDependencyAssembler createWithType:[Test1AService class] andBlock:^id _Nonnull(DependencyContainer * _Nonnull container) {
        return [[Test1AService alloc] init];
    }];
    [self.container register:assembler];
    [self.container setup];
    
    Test1BService *res1 = [self.container resolveByClass:[Test1BService class]];
    XCTAssertNil(res1);
}


@end
