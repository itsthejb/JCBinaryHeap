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

SpecBegin(Specs)

__block JCBinaryHeap *heap = nil;
NSComparator numberComparator = ^NSComparisonResult(NSNumber *l, NSNumber *r) {
	return [l compare:r];
};
NSComparator stringComparator = ^NSComparisonResult(NSString *l, NSString *r) {
	return [l compare:r];
};

before(^{
	heap = [[JCBinaryHeap alloc] initWithComparator:numberComparator];
});

it(@"should be empty", ^{
	expect(heap.count).to.equal(0);
	expect(heap.isEmpty).to.beTruthy();
	expect(heap.allObjects).to.equal(@[]);
});

describe(@"custom initialisers", ^{
	
	it(@"should create va_args heap", ^{
		heap = [JCBinaryHeap binaryHeapWithComparator:numberComparator objects:@9, @1, @0, @23, nil];
		expect(heap.allObjects).to.equal(@[@0, @1, @9, @23]);
	});
	
	it(@"should create an array heap", ^{
		NSArray *array = @[@"foo"];
		heap = [[JCBinaryHeap alloc] initWithArray:array copyItems:NO comparator:stringComparator];
		expect(heap.allObjects).to.equal(array);
		expect(heap.head == array.firstObject).to.beTruthy();
	});
	
	it(@"should create an array heap, copied objects", ^{
		NSArray *array = @[@"foo"];
		heap = [[JCBinaryHeap alloc] initWithArray:array copyItems:YES comparator:stringComparator];
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
				[heap apply:^(NSNumber *number) {
					[mapped addObject:@(number.unsignedIntegerValue * 3)];
				}];
			});
			
			it(@"should have applied mapping", ^{
				expect(mapped).to.equal(@[@3, @30, @300]);
			});
		});
	});
});

describe(@"edge cases", ^{
	it(@"should handle remove from empty heap", ^{
		heap = [JCBinaryHeap binaryHeapWithComparator:numberComparator];
		expect(heap.removeObject).to.beNil();
	});
});

SpecEnd
