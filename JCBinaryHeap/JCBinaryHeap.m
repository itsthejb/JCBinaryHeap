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
@end

static NSString const *const _jc_heapSelectorComparatorKey = @"SelectorComparator";
NSComparator JCBinaryHeapCompareSelectorComparator = ^(id l, id r) {
  return [l compare:r];
};

static NSString const *const _jc_heapSelectorReverseComparatorKey = @"SelectorReverseComparator";
NSComparator JCBinaryHeapCompareSelectorReverseComparator = ^(id l, id r) {
  return [r compare:l];
};

NS_INLINE NSString const *const _jc_heapEncodingKeyForComparator(NSComparator comparator) {
  if (comparator == JCBinaryHeapCompareSelectorComparator) {
    return _jc_heapSelectorComparatorKey;
  }
  if (comparator == JCBinaryHeapCompareSelectorReverseComparator) {
    return _jc_heapSelectorReverseComparatorKey;
  }
  return nil;
};

NS_INLINE NSComparator _jc_heapComparatorForEncodingKey(NSString *encodingKey) {
  static NSDictionary *map = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    map = @{
            _jc_heapSelectorComparatorKey : JCBinaryHeapCompareSelectorComparator,
            _jc_heapSelectorReverseComparatorKey : JCBinaryHeapCompareSelectorReverseComparator
            };
  });
  return map[encodingKey];
}

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

static void _jc_heapEnumerationCallBack(const void *val, void *context) {
  void (^block)(id object) = (__bridge void (^)(__strong id))(context);
  block((__bridge id)(val));
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
    free(cfValues);
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

- (void) enumerateObjectsUsingBlock:(void (^)(id object)) block {
  @synchronized(self) {
    CFBinaryHeapApplyFunction(self.heap, &_jc_heapEnumerationCallBack, (__bridge void *)(block));
  }
}

#pragma mark Query

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

- (BOOL) containsObject:(id) object {
  BOOL contains = NO;
  @synchronized(self) {
    contains = CFBinaryHeapContainsValue(self.heap, (__bridge const void *)(object));
  }
  return contains;
}

- (NSUInteger) countOfObject:(id) object {
  NSUInteger count = 0;
  @synchronized(self) {
    count = CFBinaryHeapGetCountOfValue(self.heap, (__bridge const void *)(object));
  }
  return count;
}

#pragma mark Object

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }
  if ([object isKindOfClass:[self class]]) {
    return [self isEqualToBinaryHeap:object];
  }
  return NO;
}

- (BOOL) isEqualToBinaryHeap:(JCBinaryHeap*) heap {
  return [self.allObjects isEqual:heap.allObjects];
}

- (NSUInteger)hash {
  // TODO:
  return 0;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
  JCBinaryHeap *copy = [[JCBinaryHeap alloc] initWithComparator:self.comparator];
  @synchronized(self) {
    copy.heap = CFBinaryHeapCreateCopy(NULL, self.count, self.heap);
  }
  return copy;
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
  NSString const * const comparatorEncodingKey = _jc_heapEncodingKeyForComparator(self.comparator);
  NSAssert(comparatorEncodingKey, @"Can't encode comparator. Use provided comparators for NSCoding.");
  [aCoder encodeObject:comparatorEncodingKey forKey:@"comparatorEncodingKey"];
  [aCoder encodeObject:self.allObjects forKey:@"allObjects"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  NSString *comparatorEncodingKey = [aDecoder decodeObjectForKey:@"comparatorEncodingKey"];
  NSComparator comparator = _jc_heapComparatorForEncodingKey(comparatorEncodingKey);
  NSAssert1(comparator, @"Could not decode comparator with key %@", comparatorEncodingKey);
  NSArray *allObjects = [aDecoder decodeObjectForKey:@"allObjects"];
  return [self initWithArray:allObjects comparator:comparator];
}

#pragma mark NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])buffer
                                    count:(NSUInteger)len
{
  CFBinaryHeapRef heapCopy = NULL;
  CFIndex size = 0;

  if (state->state == 0) {
    @synchronized(self) {
      CFIndex size = CFBinaryHeapGetCount(self.heap);
      heapCopy = CFBinaryHeapCreateCopy(NULL, size, self.heap);
      state->mutationsPtr = (unsigned long*) self.heap;
    }
    state->extra[0] = size;
    state->extra[1] = (unsigned long) heapCopy;
    state->state = 1;
  }

  size = state->extra[0];
  heapCopy = (CFBinaryHeapRef) state->extra[1];
  const void *value;

  if (CFBinaryHeapGetMinimumIfPresent(heapCopy, &value)) {
    CFBinaryHeapRemoveMinimumValue(heapCopy);
    __unsafe_unretained id object = (__bridge id)(value);
    state->itemsPtr = &object;

    if (size == 1) {
      CFRelease(heapCopy);
    } else {
      state->extra[0] = size - 1;
    }
    return 1;
  } else {
    return 0;
  }
}

@end
