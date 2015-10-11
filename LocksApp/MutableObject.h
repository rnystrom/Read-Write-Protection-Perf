//
//  MutableObject.h
//  Locks
//
//  Created by Ryan Nystrom on 10/10/15.
//  Copyright © 2015 Ryan Nystrom. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LockingStrategy) {
    // uses self as a mutex with @synchronized
    LockingStrategySynchronized = 0,
    // OSSpinLock
    LockingStrategySpinlock,
    // serial writes with barrier_async and concurrent reads
    LockingStrategyGCD,
    // NSLock
    LockingStrategyNSLock,
    // pthread_mutex_t
    LockingStrategyPThreadMutex
};

@interface MutableObject : NSObject

- (instancetype)initWithLockingStrategy:(LockingStrategy)lockingStrategy;

// syncronously return name data using the locking strategy
- (NSString *)name;

// (a)syncronously set name data using the locking strategy
- (void)setName:(NSString *)name;

@end
