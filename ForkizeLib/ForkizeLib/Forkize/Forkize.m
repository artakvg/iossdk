//
//  Forkize.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "Forkize.h"

#import <UIKit/UIKit.h>

#import "ForkizeFull.h"
#import "ForkizeEmpty.h"

@implementation Forkize

+(id<IForkize>) getInstance{
    static id<IForkize> sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSInteger version = [[UIDevice currentDevice].systemVersion floatValue];
        if (version >= 8.0) {
            sharedInstance = [[ForkizeFull alloc] init];
        } else {
            sharedInstance = [[ForkizeEmpty alloc] init];
        }
        
    });
    return sharedInstance;
}

@end
