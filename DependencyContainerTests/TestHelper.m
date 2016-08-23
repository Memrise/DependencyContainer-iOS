//
//  TestHelper.m
//  DependencyContainer
//
//  Created by Wojciech Chojnacki on 23/08/2016.
//  Copyright © 2016 Memrise. All rights reserved.
//
#import "TestHelper.h"

@implementation XCTestCase (Helper)

- (BOOL)mr_isExceptionInBlock:(void(^)())block {
    BOOL isException = NO;
    @try {
        block();
    } @catch (NSException *exception) {
        isException = YES;
    }
    
    return isException;
}

@end
