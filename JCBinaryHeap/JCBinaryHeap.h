//
//  JCBinaryHeap.h
//  JCBinaryHeap
//
//  Created by Jonathan Crooke on 7/12/2014.
//  Copyright (c) 2014 Jonathan Crooke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCBinaryHeap : NSObject
- (instancetype) initWithComparator:(NSComparator) comparator;
- (void) addObject:(id) object;
- (id) removeHead;
- (id) head;
- (void) removeAllObjects;
- (BOOL) isEmpty;
- (NSUInteger) count;
- (NSArray*) allObjects;
@end
