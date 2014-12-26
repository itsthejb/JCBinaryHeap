//
//  JCBinaryHeap.h
//  JCBinaryHeap
//
//  Created by Jonathan Crooke on 7/12/2014.
//  Copyright (c) 2014 Jonathan Crooke. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 OO-wrapper for `CFBinaryHeap`
 */
@interface JCBinaryHeap : NSObject

+ (instancetype)binaryHeapWithComparator:(NSComparator) comparator;
+ (instancetype)binaryHeapWithObject:(id)anObject
													comparator:(NSComparator) comparator;
+ (instancetype)binaryHeapWithObjects:(const id [])objects
																count:(NSUInteger)cnt
													 comparator:(NSComparator) comparator;
+ (instancetype)binaryHeapWithComparator:(NSComparator) comparator
																 objects:(id)anObject, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)binaryHeapWithArray:(NSArray *)array
												 comparator:(NSComparator) comparator;

- (instancetype)initWithComparator:(NSComparator) comparator; /* designated initializer */
- (instancetype)initWithObjects:(const id [])objects
													count:(NSUInteger)cnt
										 comparator:(NSComparator) comparator;	/* designated initializer */

- (instancetype)initWithComparator:(NSComparator) comparator
													 objects:(id)anObject, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithArray:(NSArray *)binaryHeap
									 comparator:(NSComparator) comparator;
- (instancetype)initWithArray:(NSArray *)binaryHeap
										copyItems:(BOOL)flag
									 comparator:(NSComparator) comparator;

- (id) head;
- (NSArray*) allObjects;

- (void) addObject:(id) object;
- (void) addObjectsFromArray:(NSArray*) array;

- (id) removeObject;
- (void) removeAllObjects;

- (void) apply:(void (^)(id object)) block;

- (BOOL) isEmpty;
- (NSUInteger) count;
@end
