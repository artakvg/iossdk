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
#import "UserProfile.h"

@interface SessionInstance()

@property (nonatomic, strong) NSString *sessionToken; // FZ:TODO Artak where we use it????

@property (nonatomic, assign) long sessionStartTime;
@property (nonatomic, assign) long sessionResumeTime;
@property (nonatomic, assign) long sessionEndTime;
@property (nonatomic, assign) long sessionLength;

// FZ::DONE change to boolean
@property (nonatomic, assign) BOOL isDestroyed;
@property (nonatomic, assign) BOOL isPaused;

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
        self.isDestroyed = YES;
    }
    
    return self;
}

-(void) start{
    long currentTime = [ForkizeHelper getTimeIntervalSince1970];
    if(currentTime > self.sessionEndTime || self.isDestroyed ) {
        self.sessionStartTime = currentTime;
        self.sessionResumeTime = currentTime;
        self.sessionEndTime = currentTime + [[ForkizeConfig getInstance] SESSION_INTERVAL];
        self.sessionLength = 0;
        // set isDestroyed to FALSE
        self.isDestroyed = NO;
        self.isPaused = NO;
        // ** generate session token
        self.sessionToken = [self generateSessionToken];
        [[ForkizeEventManager getInstance] queueSessionStart];
    }
}

-(void) end{
    if(!self.isDestroyed) {
        self.isDestroyed = YES;
        self.sessionLength += [ForkizeHelper getTimeIntervalSince1970] - self.sessionResumeTime;
        return [[ForkizeEventManager getInstance] queueSessionEnd];
    }
    self.sessionLength = 0; // FZ::TODO why we not do this before
}

-(void) pause{
    if(!self.isPaused) {
        self.isPaused = YES;
        self.sessionLength += [ForkizeHelper getTimeIntervalSince1970] - self.sessionResumeTime;
    }
}

-(void) resume {
    if(self.isPaused) {
        self.isPaused = NO;
        self.sessionResumeTime = [ForkizeHelper getTimeIntervalSince1970];
        if (self.sessionResumeTime > self.sessionEndTime) {
            [self end];
            [self start];
        }
    }
}
//FZ::TODO Artak where it calls

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
    
    
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)[ForkizeHelper getTimeIntervalSince1970] / 1000];
    NSString *hexDigest = [ForkizeHelper md5:[NSString stringWithFormat:@"%@%@%@", userId, timestamp, appKey]];
    self.sessionToken = [NSString stringWithFormat:@"%@=%@=%@=%@", appId, userId, timestamp, hexDigest];
    return self.sessionToken;
}

@end
