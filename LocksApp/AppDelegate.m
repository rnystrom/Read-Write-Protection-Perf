//
//  AppDelegate.m
//  LocksApp
//
//  Created by Ryan Nystrom on 10/10/15.
//  Copyright © 2015 Ryan Nystrom. All rights reserved.
//

#import "AppDelegate.h"

#import "MutableObject.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)profileLockingStrategy:(LockingStrategy)lockingStrategy withName:(NSString *)name {
    NSUInteger iterations = 100000;
    MutableObject *object = [[MutableObject alloc] initWithLockingStrategy:lockingStrategy];
    CFTimeInterval running = 0.0;
    for (NSInteger i = 0; i < iterations; i++) {
        CFTimeInterval stamp = CFAbsoluteTimeGetCurrent();
        [object name];
        running += (CFAbsoluteTimeGetCurrent() - stamp);
    }
    NSLog(@"%@ reads: %.3fms", name, running * 1000.0);
    running = 0.0;
    for (NSInteger i = 0; i < iterations; i++) {
        CFTimeInterval stamp = CFAbsoluteTimeGetCurrent();
        [object setName:@"Ryan"];
        running += (CFAbsoluteTimeGetCurrent() - stamp);
    }
    NSLog(@"%@ reads: %.3fms", name, running * 1000.0);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//  iphone 6s results:
//          sync    spin	GCD     NSLock	pthread
//    read	25.096	9.091	17.757	13.715	10.238
//    write	25.12	9.875	200.087	14.981	11.805
    [self profileLockingStrategy:LockingStrategyGCD withName:@"GCD"];
    [self profileLockingStrategy:LockingStrategySynchronized withName:@"@synchronized"];
    [self profileLockingStrategy:LockingStrategySpinlock withName:@"spinlock"];
    [self profileLockingStrategy:LockingStrategyPThreadMutex withName:@"pthread"];
    [self profileLockingStrategy:LockingStrategyNSLock withName:@"NSLock"];
    return YES;
}

@end
