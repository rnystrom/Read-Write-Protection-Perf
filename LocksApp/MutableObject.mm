//
//  MutableObject.m
//  Locks
//
//  Created by Ryan Nystrom on 10/10/15.
//  Copyright © 2015 Ryan Nystrom. All rights reserved.
//

#import "MutableObject.h"

#import <libkern/OSAtomic.h>
#import <pthread.h>

@interface MutableObject () {
    NSString *_name;
    LockingStrategy _lockingStrategy;
    dispatch_queue_t _queue;
    OSSpinLock _spinLock;
    NSLock *_lock;
    pthread_mutex_t _mutex;
}

@end

@implementation MutableObject

- (instancetype)initWithLockingStrategy:(LockingStrategy)lockingStrategy {
    if (self = [super init]) {
        _lockingStrategy = lockingStrategy;
        _queue = dispatch_queue_create("com.whoisryannystrom.mutableobject", DISPATCH_QUEUE_CONCURRENT);
        _spinLock = OS_SPINLOCK_INIT;
        _lock = [NSLock new];
        _mutex = PTHREAD_MUTEX_INITIALIZER;
    }
    return self;
}

- (NSString *)name {
    switch (_lockingStrategy) {
        case LockingStrategySynchronized:
            @synchronized(self) {
                return _name;
            }
        case LockingStrategySpinlock: {
            NSString *name;
            OSSpinLockLock(&_spinLock);
            name = _name;
            OSSpinLockUnlock(&_spinLock);
            return name;
        }
        case LockingStrategyGCD: {
            __block NSString *name;
            dispatch_sync(_queue, ^{
                name = _name;
            });
            return name;
        }
        case LockingStrategyNSLock: {
            NSString *name;
            [_lock lock];
            name = _name;
            [_lock unlock];
            return name;
        }
        case LockingStrategyPThreadMutex: {
            NSString *name;
            pthread_mutex_lock(&_mutex);
            name = _name;
            pthread_mutex_unlock(&_mutex);
            return name;
        }
    }
}

- (void)setName:(NSString *)name {
    switch (_lockingStrategy) {
        case LockingStrategySynchronized:
            @synchronized(self) {
                _name = name;
            }
            break;
        case LockingStrategySpinlock:
            OSSpinLockLock(&_spinLock);
            _name = name;
            OSSpinLockUnlock(&_spinLock);
            break;
        case LockingStrategyGCD: {
            dispatch_barrier_async(_queue, ^{
                _name = name;
            });
        }
            break;
        case LockingStrategyNSLock:
            [_lock lock];
            _name = name;
            [_lock unlock];
            break;
        case LockingStrategyPThreadMutex:
            pthread_mutex_lock(&_mutex);
            _name = name;
            pthread_mutex_unlock(&_mutex);
            break;
    }
}

@end
