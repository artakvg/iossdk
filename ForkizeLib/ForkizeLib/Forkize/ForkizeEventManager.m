//
//  ForkizeEventManager.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "ForkizeEventManager.h"

#import "UserProfile.h"
#import "SessionInstance.h"
#import "LocationInstance.h"
#import "LocalStorageManager.h"
#import "DeviceInfo.h"
#import "ForkizeHelper.h"

#import "FZEvent.h"
#import "ForkizeDefines.h"

@interface FzEventOperation : NSOperation{
    NSString *eventJSON_;
}

-(instancetype) initWithEventJSON:(NSString*) eventJSON;


@end

@implementation FzEventOperation

-(instancetype) initWithEventJSON:(NSString*) eventJSON{
    self = [super init];
    
    if (self) {
        eventJSON_ = eventJSON;
    }
    
    return self;
}

- (void)main {
    
    @autoreleasepool {
        @try {
            FZLog(@"Forkize SDK %@ event queued", eventJSON_);
            FZEvent *event = [[FZEvent alloc] init];
            event.eventData = eventJSON_;
            event.userId = [[UserProfile getInstance] getUserId];
            
            [[LocalStorageManager getInstance] addEvent:event];
        }
        @catch (NSException *exception) {
            FZLog(@"Forkize SDK Unable to insert into local storage %@", exception);
        }
    }
}

@end

@interface ForkizeEventManager()

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) NSMutableDictionary *scheduledEvents;
@property (nonatomic, strong) NSMutableDictionary *superPropertiesInternal;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@property (nonatomic, strong) NSString *state;
@property (nonatomic, assign) long stateStartTime;
@property (nonatomic, assign) long statePauseTime;
@property (nonatomic, assign) long stateResumeTime;

@end

@implementation ForkizeEventManager

-(instancetype) init{
    self = [super init];
    
    if (self) {
        self.latitude = 0;
        self.longitude = 0;
        
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.name = @"Forkize Lib Events Queue";
        self.queue.maxConcurrentOperationCount = 1;
    }
    
    return self;
}

+ (ForkizeEventManager*) getInstance{
    static ForkizeEventManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ForkizeEventManager alloc] init];
    });
    return sharedInstance;
}


-(void) eventDuration:(NSString*) eventName{
    if (self.scheduledEvents == nil){
        self.scheduledEvents = [NSMutableDictionary dictionary];
    }

    [self.scheduledEvents setObject:[NSString stringWithFormat:@"%ld", (long)[ForkizeHelper getTimeIntervalSince1970]] forKey:eventName];
}

-(void) setSuperProperties:(NSDictionary *) dict{
    if (self.superPropertiesInternal == nil) {
        self.superPropertiesInternal = [NSMutableDictionary dictionary];
    }
    
    NSArray *keys = [dict allKeys];
    
    for (NSString *key in keys) {
        if ([ForkizeHelper isKeyValid:key]) {
            [self.superPropertiesInternal setValue:[dict objectForKey:key] forKey:key];
        }
    }
}

-(void) setSuperPropertiesOnce:(NSDictionary *) dict{
    if (self.superPropertiesInternal == nil) {
        self.superPropertiesInternal = [NSMutableDictionary dictionary];
    }
    
    NSArray *keys = [dict allKeys];
    
    for (NSString *key in keys) {
        if ([ForkizeHelper isKeyValid:key] && ([self.superPropertiesInternal objectForKey:key] == nil)) {
            [self.superPropertiesInternal setValue:[dict objectForKey:key] forKey:key];
        }
    }
}

-(void) queueSessionStart {
    [self queueEventWithName:@"$session_start" andParams:nil];
}

-(void) queueSessionEnd{
    
    NSDictionary * params = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%ld", [SessionInstance getInstance].sessionLength] forKey:@"$session_duration"];
    
    [self queueEventWithName:@"$session_end" andParams:params];
}

-(void) queueEventWithName:(NSString*) eventName andParams:(NSDictionary *)params{
    @try {
        NSString *eventString = [self eventAsJSON:eventName andParameters:params];
        [self.queue addOperation:[[FzEventOperation alloc] initWithEventJSON:eventString]];
    }
    @catch (NSException *exception) {
        FZLog(@"Forkize SDK Error when queue event %@", exception);
    }
}


-(NSString*) eventAsJSON:(NSString*) event andParameters:(NSDictionary *) parameters //throws JSONException
{
    NSTimeInterval timeInterval = [ForkizeHelper getTimeIntervalSince1970];
    
    NSTimeInterval sessionTime = timeInterval -[SessionInstance getInstance].sessionStartTime;
                                  
    NSMutableDictionary * jsonEVDDict = [NSMutableDictionary dictionary];
    [jsonEVDDict setObject:[[DeviceInfo getInstance] getBatteryLevel] forKey:@"$battery_level"];
    
    
   // [jsonDict setObject:[[UserProfile getInstance] getUserId] forKey:USER_ID];
   // [jsonDict setObject:[ForkizeConfig getInstance].appId  forKey:APP_ID];
    [jsonEVDDict setObject:[NSString stringWithFormat:@"%ld", (long)timeInterval]  forKey:@"$utc_time"];
    [jsonEVDDict setObject:[NSString stringWithFormat:@"%ld", (long)sessionTime]  forKey:@"$session_time"];
   
    NSString *sessionId = [[SessionInstance getInstance] getSessionId];
    if (sessionId != nil && [sessionId length] == 0) {
        [jsonEVDDict setObject:sessionId forKey:@"$sid"];
    }
    
    
    if (self.scheduledEvents != nil){
        NSInteger time = [[self.scheduledEvents valueForKey:event] integerValue];
        if (time != 0) {
            [jsonEVDDict setObject:[NSString stringWithFormat:@"%ld", (long)timeInterval - time] forKey:@"$event_duration"];
            [self.scheduledEvents removeObjectForKey:event];
        }
    }
    
    
    if (self.state != nil) {
        [jsonEVDDict setObject:self.state forKey:@"$state"];
        NSTimeInterval stateTime = timeInterval - self.stateStartTime;
        
        [jsonEVDDict setObject:[NSString stringWithFormat:@"%ld", (long)stateTime] forKey:@"$state_time"];
    }
    
    self.latitude = [[LocationInstance getInstance] latitude];
    self.longitude = [[LocationInstance getInstance] longitude];
    
    if (self.latitude != 0 && self.longitude != 0) {
        [jsonEVDDict setObject:[NSString stringWithFormat:@"%f", self.longitude] forKey:@"$longitude"];
        [jsonEVDDict setObject:[NSString stringWithFormat:@"%f", self.latitude] forKey:@"$latitude"];
    }
    
    NSString *connectionType = [[DeviceInfo getInstance] getConnectionType];
    
    if (![connectionType isEqualToString:@"ncon"])
         [jsonEVDDict setObject:connectionType forKey:@"$connection"];
    
    if (parameters != nil && [parameters count] > 0) {
     
        for (NSString *key in parameters) {
            [jsonEVDDict setObject:[parameters objectForKey:key] forKey:key];
        }
    }
    
    for (NSString *key in [self.superPropertiesInternal allKeys]) {
        [jsonEVDDict setObject:[self.superPropertiesInternal objectForKey:key]  forKey:key];
    }
    
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:jsonEVDDict, @"evd", event, @"evn", nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    NSString *resultString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return resultString;
}

-(void) close{
    [self.queue cancelAllOperations];
    self.queue = nil;
    [[LocalStorageManager getInstance] close];
}


-(void) advanceState:(NSString *) state{
    long currentTime = [ForkizeHelper getTimeIntervalSince1970];

    NSString *oldState = self.state;
    self.state = state;
    
    if (oldState != nil ) {
        long duration = currentTime - self.stateStartTime;
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                oldState, @"$state_prev",
                                self.state, @"$state_next",
                                [NSString stringWithFormat:@"%ld", duration], @"$state_duration", nil];
        [self queueEventWithName:@"$state_advance" andParams:params];
    }
    
    self.stateStartTime = currentTime;
    self.stateResumeTime = currentTime;
}


-(void) resetState:(NSString *) state{
    long currentTime = [ForkizeHelper getTimeIntervalSince1970];
    
    long duration = currentTime - self.stateStartTime;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"", @"$state_prev",
                            self.state, @"$state_next",
                            [NSString stringWithFormat:@"%ld", duration], @"$state_duration", nil];
    [self queueEventWithName:@"$state_advance" andParams:params];
    
    self.state = nil;
}

-(void) pauseState:(NSString *) state{
    long currentTime = [ForkizeHelper getTimeIntervalSince1970];
    self.statePauseTime = currentTime;
}

-(void) resumeState:(NSString *) state{
    long currentTime = [ForkizeHelper getTimeIntervalSince1970];
    self.stateResumeTime = currentTime;
    self.stateStartTime += (self.stateResumeTime - self.statePauseTime);
}

-(void) flushCacheToDatabase{
    [[LocalStorageManager getInstance] flushToDatabase];
}

@end

