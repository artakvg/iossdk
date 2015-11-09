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

@property (nonatomic, assign) long sessionStartTime;
@property (nonatomic, assign) long sessionResumeTime;
@property (nonatomic, assign) long sessionEndTime;
@property (nonatomic, assign) long sessionLength;

// FZ::TODO change to boolean
@property (nonatomic, assign) long isDestroyed;
@property (nonatomic, assign) long isPaused;

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
        self.sessionStartTime = 0;
        self.sessionEndTime = 0;
        self.sessionLength = 0;
        self.isDestroyed = 1;
    }
    
    return self;
}

-(void) start{
    long currentTime = [[NSDate date] timeIntervalSince1970];
    if(currentTime > self.sessionEndTime || self.isDestroyed == 1 ) {
        self.sessionStartTime = currentTime;
        self.sessionResumeTime = currentTime;
        self.sessionEndTime = currentTime + [[ForkizeConfig getInstance] SESSION_INTERVAL];
        self.sessionLength = 0;
        // set isDestroyed to FALSE
        self.isDestroyed = 0;
        self.isPaused = 0;
        // ** generate session token
        self.sessionToken = [self generateSessionToken];
        [[ForkizeEventManager getInstance] queueSessionStart];
    }
}

-(void) end{
    if(self.isDestroyed == 0) {
        self.isDestroyed = 1;
        self.sessionLength += [[NSDate date] timeIntervalSince1970] - self.sessionResumeTime;
        return [[ForkizeEventManager getInstance] queueSessionEnd];
    }
}

-(void) pause{
    if(self.isPaused == 0) {
        self.isPaused = 1;
        self.sessionLength += [[NSDate date] timeIntervalSince1970] - self.sessionResumeTime;
    }
}

-(void) resume {
    if(self.isPaused == 1) {
        self.sessionResumeTime = [[NSDate date] timeIntervalSince1970];
        if (self.sessionResumeTime > self.sessionEndTime) {
            [self end];
            [self start];
        }
    }
}

-(NSString*) getSessionToken{
    return  [self generateSessionToken];
}

- (long) getSessionLength{
    return self.sessionLength;
}

-(NSString*) generateSessionToken {
    NSString* userId = [[UserProfile getInstance] getUserId];
    NSString* appId = [[ForkizeConfig getInstance] appId];
    NSString* appKey = [[ForkizeConfig getInstance] appKey];
    
    
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970] / 1000];
    NSString *hexDigest = [ForkizeHelper md5:[NSString stringWithFormat:@"%@%@%@", userId, timestamp, appKey]];
    self.sessionToken = [NSString stringWithFormat:@"%@=%@=%@=%@", appId, userId, timestamp, hexDigest];
    return self.sessionToken;
}

@end
