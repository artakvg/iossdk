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
@property (nonatomic, assign) NSInteger REQUEST_TIMEOUT;
@property (nonatomic, strong) NSString *SDK_VERSION;


@end

@implementation ForkizeConfig

-(instancetype) init{
    self = [super init];
    if (self) {
        
        NSInteger maxEventsPerFlush = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"ForkizeMaxEventsPerFlush"] integerValue];
        NSInteger timeAfterFlush = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"ForkizeTimeAfterFlush"] integerValue];
        NSInteger requestTimout = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"ForkizeRequestTimout"] integerValue];
        
        self.MAX_EVENTS_PER_FLUSH = (maxEventsPerFlush != 0 ? maxEventsPerFlush : 10);
        self.TIME_AFTER_FLUSH = (timeAfterFlush != 0 ? timeAfterFlush : 10);
        self.REQUEST_TIMEOUT = (requestTimout != 0 ? requestTimout : 5);

        self.SESSION_INTERVAL = 7200;
        self.SDK_VERSION = FORKIZE_SDK_VERION;
        self.BASE_URL = [NSString stringWithFormat:@"http://fzgate.cloudapp.net:8080/%@/", self.SDK_VERSION];
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
