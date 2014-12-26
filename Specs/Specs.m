//
//  Specs.m
//  JCBinaryHeap
//
//  Created by Jonathan Crooke on 26/12/2014.
//  Copyright (c) 2014 Jonathan Crooke. All rights reserved.
//

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <Specta/Specta.h>
#import "JCBinaryHeap.h"

@interface JCBinaryHeap ()
@property (assign) CFBinaryHeapRef heap;
@end

SpecBegin(Specs)

__block JCBinaryHeap *heap = nil;

before(^{
	heap = [[JCBinaryHeap alloc] initWithComparator:JCBinaryHeapCompareSelectorComparator];
});

it(@"should be empty", ^{
	expect(heap.count).to.equal(0);
	expect(heap.isEmpty).to.beTruthy();
	expect(heap.allObjects).to.equal(@[]);
});

describe(@"custom initialisers", ^{
	
	it(@"should create va_args heap", ^{
		heap = [JCBinaryHeap binaryHeapWithComparator:JCBinaryHeapCompareSelectorComparator
																					objects:@9, @1, @0, @23, nil];
		expect(heap.allObjects).to.equal(@[@0, @1, @9, @23]);
	});
	
	it(@"should create an array heap", ^{
		NSArray *array = @[@"foo"];
		heap = [[JCBinaryHeap alloc] initWithArray:array
																		 copyItems:NO
																		comparator:JCBinaryHeapCompareSelectorComparator];
		expect(heap.allObjects).to.equal(array);
		expect(heap.head == array.firstObject).to.beTruthy();
	});
	
	it(@"should create an array heap, copied objects", ^{
		NSArray *array = @[@"foo"];
		heap = [[JCBinaryHeap alloc] initWithArray:array
																		 copyItems:YES
																		comparator:JCBinaryHeapCompareSelectorComparator];
		expect(heap.allObjects).to.equal(array);
		expect(heap.head == array.firstObject).to.beTruthy();
	});
});

describe(@"basic functionality", ^{
	
	before(^{
		[heap addObject:@10];
	});
	
	it(@"should add an object", ^{
		expect(heap.count).to.equal(1);
		expect(heap.isEmpty).to.beFalsy();
		expect(heap.allObjects).to.equal(@[@10]);
	});
	
	it(@"should pop an object", ^{
		[heap removeObject];
		expect(heap.count).to.equal(0);
		expect(heap.isEmpty).to.beTruthy();
	});
	
	describe(@"larger heap", ^{
		
		before(^{
			[heap addObject:@1];
			[heap addObject:@100];
		});
		
		it(@"should have expected state", ^{
			expect(heap.count).to.equal(3);
			expect(heap.isEmpty).to.beFalsy();
			expect(heap.allObjects).to.equal(@[@1, @10, @100]);
		});
		
		describe(@"mapping", ^{
			
			__block NSMutableArray *mapped = nil;
			
			before(^{
				mapped = @[].mutableCopy;
				[heap enumerateObjectsUsingBlock:^(NSNumber *number) {
					[mapped addObject:@(number.unsignedIntegerValue * 3)];
				}];
			});
			
			it(@"should have applied mapping", ^{
				expect(mapped).to.equal(@[@3, @30, @300]);
			});
		});
	});
});

describe(@"protocols", ^{
	before(^{
		heap = [JCBinaryHeap binaryHeapWithArray:@[@4, @1, @78]
																	comparator:JCBinaryHeapCompareSelectorComparator];
	});
	
	it(@"should create a copy", ^{
		JCBinaryHeap *copy = heap.copy;
		expect(heap.allObjects).to.equal(copy.allObjects);
		expect(heap.heap == copy.heap).to.beFalsy();
	});
	
	it(@"should serialise", ^{
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:heap];
		JCBinaryHeap *decoded = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		expect(decoded).to.equal(heap);
	});
	
	it(@"should enumerate", ^{
		for (NSUInteger i = 0; i < 100; ++i) {
			NSNumber *rand = @(arc4random() % 20);
			[heap addObject:rand];
		}

		NSMutableArray *array = @[].mutableCopy;
		for (id obj in heap) {
			[array addObject:obj];
		}

		expect([array sortedArrayUsingSelector:@selector(compare:)]).to.equal([heap.allObjects sortedArrayUsingSelector:@selector(compare:)]);
	});
});

describe(@"edge cases", ^{
	it(@"should handle remove from empty heap", ^{
		heap = [JCBinaryHeap binaryHeapWithComparator:JCBinaryHeapCompareSelectorComparator];
		expect(heap.removeObject).to.beNil();
	});
});

SpecEnd
