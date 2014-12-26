//
//  JCBinaryHeap.m
//  JCBinaryHeap
//
//  Created by Jonathan Crooke on 7/12/2014.
//  Copyright (c) 2014 Jonathan Crooke. All rights reserved.
//

#import "JCBinaryHeap.h"

@interface JCBinaryHeap () {
	CFBinaryHeapRef _heap;
}
@property (copy) NSComparator comparator;
@end

static const void *_jc_heapRetainCallback(CFAllocatorRef ref, const void *ptr) {
	return CFRetain(ptr);
}

static void _jc_heap_releaseCallback(CFAllocatorRef ref, const void *ptr) {
	CFRelease(ptr);
}

static CFStringRef _jc_heap_copyDescriptionCallback(const void *ptr) {
	id object = (__bridge id)(ptr);
	return CFBridgingRetain([object description]);
}

static CFComparisonResult _jc_heapCompareCallback(const void *ptr1, const void *ptr2, void *context) {
	JCBinaryHeap *heap = (__bridge JCBinaryHeap *)(context);
	return (CFComparisonResult) heap.comparator((__bridge id)(ptr1), (__bridge id)(ptr2));
}

@implementation JCBinaryHeap

- (instancetype) initWithComparator:(NSComparator) comparator
{
	NSParameterAssert(comparator);
	if ((self = [super init])) {
		CFBinaryHeapCallBacks callBacks = {
			.version = 0,
			.retain = _jc_heapRetainCallback,
			.release = _jc_heap_releaseCallback,
			.copyDescription = _jc_heap_copyDescriptionCallback,
			.compare = _jc_heapCompareCallback
		};
		CFBinaryHeapCompareContext context = {
			.version = 0,
			.info = (__bridge void *)(self),
			.retain = CFRetain,
			.release = CFRelease,
			.copyDescription = CFCopyDescription
		};
		_heap = CFBinaryHeapCreate(NULL, 0, &callBacks, &context);
		self.comparator = comparator;
	}
	return self;
}

- (void)dealloc {
	CFRelease(_heap);
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@%@", super.description, self.allObjects];
}

- (void) addObject:(id) object {
	@synchronized(self) {
		CFBinaryHeapAddValue(_heap, (__bridge const void *)(object));
	}
}

- (id) removeHead {
	@synchronized(self) {
		id head = [self head];
		CFBinaryHeapRemoveMinimumValue(_heap);
		return head;
	}
}

- (void)removeAllObjects {
	@synchronized(self) {
		CFBinaryHeapRemoveAllValues(_heap);
	}
}

- (BOOL)isEmpty {
	return self.count == 0;
}

- (NSUInteger)count {
	@synchronized(self) {
		NSUInteger count = 0;
		count = CFBinaryHeapGetCount(_heap);
		return count;
	}
}

- (id) head {
	@synchronized(self) {
		if (self.count) {
			id head = CFBinaryHeapGetMinimum(_heap);
			return head;
		}
		return nil;
	}
}

- (NSArray*) allObjects {
	@synchronized(self) {
		CFIndex size = CFBinaryHeapGetCount(_heap);
		CFTypeRef *cfValues = calloc(size, sizeof(CFTypeRef));
		CFBinaryHeapGetValues(_heap, (const void **)cfValues);
		CFArrayRef values = CFArrayCreate(kCFAllocatorDefault, cfValues, size, &kCFTypeArrayCallBacks);
		return (__bridge NSArray *)(values);
	}
}

@end
