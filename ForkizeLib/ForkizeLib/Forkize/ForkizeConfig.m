//
//  ForkizeConfig.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "ForkizeConfig.h"

NSString *const FORKIZE_SDK_VERION = @"1.0";

@interface ForkizeConfig()

@property (nonatomic, assign) NSInteger MAX_EVENTS_PER_FLUSH;
@property (nonatomic, assign) NSInteger TIME_AFTER_FLUSH;
@property (nonatomic, assign) NSInteger SESSION_INTERVAL;
@property (nonatomic, strong) NSString *SDK_VERSION;


@end

@implementation ForkizeConfig

-(instancetype) init{
    self = [super init];
    if (self) {
        self.MAX_EVENTS_PER_FLUSH = 10;
        self.TIME_AFTER_FLUSH = 10;
        // FZ::TODO::ARTAK let make it 2 hours
        self.SESSION_INTERVAL = 7200L;
        self.SDK_VERSION = FORKIZE_SDK_VERION;
        self.BASE_URL = @"http://fzgate.cloudapp.net:8080";
    }
    
    return self;
}

+ (ForkizeConfig*) getInstance {
    static ForkizeConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ForkizeConfig alloc] init];
    });
    return sharedInstance;
}


@end
