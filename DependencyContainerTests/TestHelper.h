//
//  TestHelper.h
//  DependencyContainer
//
//  Created by Wojciech Chojnacki on 23/08/2016.
//  Copyright © 2016 Memrise. All rights reserved.
//
#import <XCTest/XCTest.h>

@interface XCTestCase (Helper)
- (BOOL)mr_isExceptionInBlock:(void(^)())block;
@end
