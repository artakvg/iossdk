//
//  ForkizeInstance.m
//  ForkizeLib
//
//  Created by Artak on 9/13/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "ForkizeInstance.h"

#import <UIKit/UIKit.h>

#import "Forkize.h"
#import "ForkizeEmpty.h"

@implementation ForkizeInstance

+(id<IForkize>) getInstance{
    static id<IForkize> sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSInteger version = [[UIDevice currentDevice].systemVersion floatValue];
        if (version >= 8.0) {
            sharedInstance = [[Forkize alloc] init];
        } else {
            sharedInstance = [[ForkizeEmpty alloc] init];
        }
        
    });
    return sharedInstance;
}

@end
