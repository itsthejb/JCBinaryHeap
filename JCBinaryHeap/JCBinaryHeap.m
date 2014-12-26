//
//  JCBinaryHeap.m
//  JCBinaryHeap
//
//  Created by Jonathan Crooke on 7/12/2014.
//  Copyright (c) 2014 Jonathan Crooke. All rights reserved.
//

#import "JCBinaryHeap.h"

@interface JCBinaryHeap ()
@property (assign) CFBinaryHeapRef heap;
@property (copy) NSComparator comparator;
@property (copy) void (^mappingBlock)(id object);
@end

static const void *_jc_heapRetainCallback(CFAllocatorRef ref, const void *ptr) { return CFRetain(ptr); }
static void _jc_heap_releaseCallback(CFAllocatorRef ref, const void *ptr) {	CFRelease(ptr); }
static CFStringRef _jc_heap_copyDescriptionCallback(const void *ptr) {
	id object = (__bridge id)(ptr);
	return CFBridgingRetain([object description]);
}

static CFComparisonResult _jc_heapCompareCallback(const void *ptr1, const void *ptr2, void *context) {
	JCBinaryHeap *heap = (__bridge JCBinaryHeap *)(context);
	return (CFComparisonResult) heap.comparator((__bridge id)(ptr1), (__bridge id)(ptr2));
}

static void _jc_heapApplierCallBack(const void *val, void *context) {
	JCBinaryHeap *heap = (__bridge JCBinaryHeap *)(context);
	heap.mappingBlock((__bridge id)(val));
}

@implementation JCBinaryHeap

#pragma mark Instantiation

+ (instancetype)binaryHeapWithComparator:(NSComparator) comparator {
	return [[self alloc] initWithComparator:comparator];
}

+ (instancetype)binaryHeapWithObject:(id)anObject
													comparator:(NSComparator) comparator
{
	JCBinaryHeap *heap = [self binaryHeapWithComparator:comparator];
	[heap addObject:anObject];
	return heap;
}

+ (instancetype)binaryHeapWithObjects:(const id [])objects
																count:(NSUInteger)cnt
													 comparator:(NSComparator) comparator
{
	return [[self alloc] initWithObjects:objects count:cnt comparator:comparator];
}

+ (instancetype)binaryHeapWithComparator:(NSComparator) comparator
																 objects:(id)anObject, ...
{
	va_list list;
	va_start(list, anObject);
	JCBinaryHeap *heap = [[self alloc] initWithObject:anObject
																						va_list:list
																				 comparator:comparator];
	va_end(list);
	return heap;
}

+ (instancetype)binaryHeapWithArray:(NSArray *)array
												 comparator:(NSComparator) comparator
{
	return [[self alloc] initWithArray:array comparator:comparator];
}

- (instancetype)initWithObjects:(const id [])objects
													count:(NSUInteger)cnt
										 comparator:(NSComparator) comparator
{
	if ((self = [self initWithComparator:comparator])) {
		for (NSUInteger i = 0; i < cnt; ++i) {
			[self addObject:objects[i]];
		}
	}
	return self;
}

- (instancetype)initWithObject:(id) object
											 va_list:(va_list)list
										comparator:(NSComparator)comparator
{
	if ((self = [self initWithComparator:comparator])) {
		[self addObject:object];
		while ((object = va_arg(list, id))) {
			[self addObject:object];
		}
	}
	return self;
}

- (instancetype)initWithComparator:(NSComparator) comparator
													 objects:(id)anObject, ...
{
	va_list list;
	va_start(list, anObject);
	self = [self initWithObject:anObject
											va_list:list
									 comparator:comparator];
	va_end(list);
	return self;
}

- (instancetype)initWithArray:(NSArray *)array
									 comparator:(NSComparator) comparator
{
	if ((self = [self initWithComparator:comparator])) {
		[self addObjectsFromArray:array];
	}
	return self;
}

- (instancetype)initWithArray:(NSArray *)array
										copyItems:(BOOL)flag
									 comparator:(NSComparator) comparator
{
	if ((self = [self initWithComparator:comparator])) {
		[self addObjectsFromArray:(flag ?
															 [[NSArray alloc] initWithArray:array copyItems:flag] :
															 array)];
	}
	return self;
}

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
		self.heap = CFBinaryHeapCreate(NULL, 0, &callBacks, &context);
		self.comparator = comparator;
	}
	return self;
}

#pragma mark NSObject

- (void)dealloc {
	CFRelease(self.heap);
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@%@", super.description, self.allObjects];
}

#pragma mark Add/remove

- (void) addObject:(id) object {
	NSParameterAssert(object);
	@synchronized(self) {
		CFBinaryHeapAddValue(self.heap, (__bridge const void *)(object));
	}
}

- (void)addObjectsFromArray:(NSArray *)array {
	@synchronized(self) {
		[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			CFBinaryHeapAddValue(self.heap, (__bridge const void *)(obj));
		}];
	}
}

- (id) head {
	id head = nil;
	@synchronized(self) {
		if (self.count) {
			head = CFBinaryHeapGetMinimum(self.heap);
		}
	}
	return head;
}

- (NSArray*) allObjects {
	NSArray *allObjects = nil;
	@synchronized(self) {
		CFIndex size = CFBinaryHeapGetCount(self.heap);
		CFTypeRef *cfValues = calloc(size, sizeof(CFTypeRef));
		CFBinaryHeapGetValues(self.heap, (const void **)cfValues);
		CFArrayRef values = CFArrayCreate(kCFAllocatorDefault, cfValues, size, &kCFTypeArrayCallBacks);
		allObjects = (__bridge NSArray *)(values);
	}
	return allObjects;
}

- (id) removeObject {
	@synchronized(self) {
		id head = [self head];
		if (head) {
			CFBinaryHeapRemoveMinimumValue(self.heap);
		}
		return head;
	}
}

- (void)removeAllObjects {
	@synchronized(self) {
		CFBinaryHeapRemoveAllValues(self.heap);
	}
}

#pragma mark Function

- (void) apply:(void (^)(id object)) block {
	@synchronized(self) {
		self.mappingBlock = block;
		CFBinaryHeapApplyFunction(self.heap, &_jc_heapApplierCallBack, (__bridge void *)(self));
		self.mappingBlock = nil;
	}
}

#pragma mark Count

- (BOOL)isEmpty {
	return self.count == 0;
}

- (NSUInteger)count {
	NSUInteger count = 0;
	@synchronized(self) {
		count = CFBinaryHeapGetCount(self.heap);
	}
	return count;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
	JCBinaryHeap *copy = [[JCBinaryHeap alloc] initWithComparator:self.comparator];
	@synchronized(self) {
		copy.heap = CFBinaryHeapCreateCopy(NULL, self.count, self.heap);
	}
	return copy;
}

@end
