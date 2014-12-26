//
//  JCHeap.h
//  Merging
//
//  Created by jc on 07/12/14.
//  Copyright (c) 2014 jc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCHeap : NSObject
- (instancetype) initWithComparator:(NSComparator) comparator;
- (void) addObject:(id) object;
- (id) removeHead;
- (id) head;
- (void) removeAllObjects;
- (BOOL) isEmpty;
- (NSUInteger) count;
- (NSArray*) allObjects;
@end
