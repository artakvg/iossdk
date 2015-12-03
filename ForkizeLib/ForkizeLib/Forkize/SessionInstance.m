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

@property (nonatomic, strong) NSString *sessionId;

@property (nonatomic, assign) long sessionStartTime;
@property (nonatomic, assign) long sessionResumeTime;
@property (nonatomic, assign) long sessionPauseTime;
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
        self.isDestroyed = NO;
        self.isPaused = NO;
        // ** generate session token
        self.sessionId = [self generateSessionId];
        [[ForkizeEventManager getInstance] queueSessionStart];
    }
}

-(void) end{
    if(!self.isDestroyed) {
        self.isDestroyed = YES;
        self.sessionLength += [ForkizeHelper getTimeIntervalSince1970] - self.sessionResumeTime;
        self.sessionLength = 0;

        return [[ForkizeEventManager getInstance] queueSessionEnd];
    }
}

-(void) pause{
    if(!self.isPaused) {
        self.isPaused = YES;
        self.sessionPauseTime = [ForkizeHelper getTimeIntervalSince1970];
        self.sessionLength += self.sessionPauseTime - self.sessionResumeTime;
    }
}

-(void) resume {
    if(self.isPaused) {
        self.isPaused = NO;
        self.sessionResumeTime = [ForkizeHelper getTimeIntervalSince1970];
        self.sessionEndTime += (self.sessionResumeTime - self.sessionPauseTime);
        if (self.sessionResumeTime > self.sessionEndTime) {
            [self end];
            [self start];
        }
    }
}

-(NSString*) getSessionId{
    return self.sessionId;
}

- (long) getSessionLength{
    return self.sessionLength;
}

- (long) getSessionStartTime{
    return self.sessionStartTime;
}

-(NSString*) generateSessionId {
    self.sessionId = [NSUUID UUID].UUIDString;
    return self.sessionId;
}

@end
