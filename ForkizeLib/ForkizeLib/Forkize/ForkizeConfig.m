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

@property (nonatomic, strong) NSString *dbName;
@property (nonatomic, assign) long maxSQLiteDBSize;

@property (nonatomic, assign) NSInteger MAX_EVENTS_PER_FLUSH;
@property (nonatomic, assign) NSInteger TIME_AFTER_FLUSH;
@property (nonatomic, assign) NSInteger SESSION_INTERVAL;
@property (nonatomic, strong) NSString *SDK_VERSION;


@end

@implementation ForkizeConfig

-(instancetype) init{
    self = [super init];
    if (self) {
        self.dbName = @"forkize.db";
        self.maxSQLiteDBSize = 1048576L;
        
        self.MAX_EVENTS_PER_FLUSH = 10;
        self.TIME_AFTER_FLUSH = 10;
        self.SESSION_INTERVAL = 30000L;
        self.SDK_VERSION = FORKIZE_SDK_VERION;
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
