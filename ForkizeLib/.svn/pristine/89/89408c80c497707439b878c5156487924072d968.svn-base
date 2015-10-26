//
//  SessionInstance.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "SessionInstance.h"
#import "ForkizeConfig.h"
#import "ForkizeHelper.h"
#import "ForkizeEventManager.h"
#import "ForkizeInstance.h"
#import "UserProfile.h"

@interface SessionInstance()

@property (nonatomic, strong) NSString *sessionToken;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) long lastSessionTick;
@property (nonatomic, assign) long sessionLength;
@property (nonatomic, assign) long resumedTime;

@end

@implementation SessionInstance

+ (SessionInstance*) getInstance{
    static SessionInstance *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SessionInstance alloc] init];
    });
    return sharedInstance;
}

-(instancetype) init{
    self = [super init];
    if (self) {
        self.sessionLength = 0;
    }
    
    return self;
}

-(NSString*) getSessionToken{
    return  [self generateSessionToken:[[UserProfile getInstance] getUserId]];
}

-(void) generateNewSessionInterval {
    self.lastSessionTick = [[NSDate date] timeIntervalSince1970] + [[ForkizeConfig getInstance] newSessionInterval];
}

-(NSString*) generateSessionToken:(NSString*) userId {
    self.userId = userId;
    NSString* appId = [[ForkizeConfig getInstance] appId];
    NSString* appKey = [[ForkizeConfig getInstance] appKey];
    
    
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970] / 1000];
    NSString *hexDigest = [ForkizeHelper md5:[NSString stringWithFormat:@"%@%@%@", self.userId, timestamp, appKey]];
    self.sessionToken = [NSString stringWithFormat:@"%@=%@=%@=%@", appId, userId, timestamp, hexDigest];
    return self.sessionToken;
}

-(void) pause{
    self.sessionLength += [[NSDate date] timeIntervalSince1970] - self.resumedTime;
}

-(void) resume {
    self.resumedTime = [[NSDate date] timeIntervalSince1970];
    if (self.resumedTime > self.lastSessionTick) {
        [self generateNewSessionInterval];
        [self generateSessionToken:self.userId];
        [[ForkizeEventManager getInstance] queueSessionStart];
    }
}

- (long) getSessionLength{
    return self.sessionLength;
}

-(void) dropSessionLength {
    self.sessionLength = 0L;
}

@end
