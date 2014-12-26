#JCBinaryHeap

*OO-wrapper for `CFBinaryHeap`*

##What's This?

	CFBinaryHeap implements a container which stores values 
	sorted using a binary search algorithm.  
	CFBinaryHeaps can be useful as priority queues.
	
Since this type is implemented at the `CF` level, some amount of boiler-plate is always required and many conveniences such as equality, hashing and enumeration are not available. `JCBinaryHeap` provides a Cocoa-style OO-wrapper to make this type as convenient to use as possible, and mirrors the interface of collection classes such as `NSArray` and `NSMutableArray`.

Note that as with `CFBinaryHeap`, `JCBinaryHeap` is mutable, and has no immutable counterpart.

##Installation

Most convenientally added to your project as a [CocoaPod](www.cocoapods.org), or can also be adding as a Git submodule, and the two source files included into your target.

##ToDo
* Swift implementation? Fun with operators?

---
[jon.crooke@gmail.com](mailto:joncrooke@gmail.com)
