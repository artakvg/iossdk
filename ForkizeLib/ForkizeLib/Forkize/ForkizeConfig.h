//
//  ForkizeConfig.h
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForkizeConfig : NSObject

@property (nonatomic, readonly) NSInteger MAX_EVENTS_PER_FLUSH;
@property (nonatomic, readonly) NSInteger TIME_AFTER_FLUSH;
@property (nonatomic, readonly) NSInteger SESSION_INTERVAL;
@property (nonatomic, readonly) NSInteger REQUEST_TIMEOUT;
@property (nonatomic, readonly) NSString *SDK_VERSION;

@property (nonatomic, strong)   NSString *appId;
@property (nonatomic, strong)   NSString *appKey;

@property (nonatomic, strong) NSString *BASE_URL;

+ (ForkizeConfig*) getInstance;

@end
