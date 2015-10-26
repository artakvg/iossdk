//
//  ForkizeConfig.h
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForkizeConfig : NSObject

@property (nonatomic, readonly) NSInteger maxEventsPerFlush;
@property (nonatomic, readonly) NSInteger timeAfterFlush;
@property (nonatomic, readonly) NSString *sdkVersion;

@property (nonatomic, assign) NSInteger newSessionInterval;

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *appKey;

+ (ForkizeConfig*) getInstance;

@end
