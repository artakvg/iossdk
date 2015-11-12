//
//  ForkizeEventManager.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "ForkizeEventManager.h"
#import "UserProfile.h"
#import "ForkizeConfig.h"
#import "SessionInstance.h"
#import "LocationInstance.h"
#import "LocalStorageManager.h"
#import "DeviceInfo.h"
#import "ForkizeHelper.h"

#import "Reachability.h"
#import "FZEvent.h"




NSString *const EVENT_TYPE = @"$event";
NSString *const EVENT_VALUE = @"$value";
NSString *const EVENT_DURATION = @"$event_duration";
NSString *const BATTERY_LEVEL = @"$battery_level";

NSString *const EVENT_TIME = @"Forkize.event.time";
NSString *const PARAMS = @"Forkize.event.params";
NSString *const SESSION_START = @"Forkize.session.start";
NSString *const SESSION_END = @"Forkize.session.end";
NSString *const SESSION_LENGTH = @"Forkize.session.length";
NSString *const APP_INSTALL = @"Forkize.app.install";
NSString *const DEVICE_INFO = @"Forkize.device.info";
NSString *const USER_INFO = @"Forkize.user.info";
NSString *const USER_ID = @"Forkize.userId";
NSString *const APP_ID = @"Forkize.appId";
// FZ::DONE remove SESSION_TOKEN
//NSString *const SESSION_TOKEN = @"Forkize.session.token";
NSString *const LATITUDE = @"Forkize.latitude";
NSString *const LONGITUDE = @"Forkize.longitude";
NSString *const CONNECTION_TYPE = @"Forkize.connection.type";
NSString *const OLD_USER = @"Forkize.userId.old";
NSString *const NEW_USER = @"Forkize.userId.new";


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
            NSLog(@"Forkize SDK %@ event queued", eventJSON_);
            FZEvent *event = [[FZEvent alloc] init];
            event.eventValue = eventJSON_;
            event.userName = [[UserProfile getInstance] getUserId];
            
            [[LocalStorageManager getInstance] addEvent:event];
        }
        @catch (NSException *exception) {
            NSLog(@"Forkize SDK Unable to insert into local storage %@", exception);
        }
    }
}

@end

@interface ForkizeEventManager()

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) NSMutableDictionary *scheduledEvents;
@property (nonatomic, strong) NSMutableDictionary *superPropertiesInternal;
@property (nonatomic, strong) NSMutableDictionary *superPropertiesOnceInternal;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

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
    // FZ::DONE which timezone is timeIntervalSince1970 ????? LOOK AT TRACK EVENT
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
    if (self.superPropertiesOnceInternal == nil) {
        self.superPropertiesOnceInternal = [NSMutableDictionary dictionary];
    }
    
    NSArray *keys = [dict allKeys];
    
    for (NSString *key in keys) {
        if ([ForkizeHelper isKeyValid:key] && ([self.superPropertiesOnceInternal objectForKey:key] == nil)) {
            [self.superPropertiesOnceInternal setValue:[dict objectForKey:key] forKey:key];
        }
    }
}

// FZ::DONE THINK IT SHOULD BE REMOVED from where it was called
-(void) queueAliasWithOldUserId:(NSString*) oldUserId andNewUserId:(NSString*) newUserId{
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             oldUserId, OLD_USER,
                             newUserId, NEW_USER,
                             nil];
    [self queueEventWithName:@"alias" andValue:0 andParams:params];
    NSLog(@"Forkize SDK queueAlias has been ended job");
}

-(void) queueSessionStart {
    [self queueEventWithName:SESSION_START andValue:1 andParams:nil];
}

// FZ::DONE , think session time should be retrieved from session instance
-(void) queueSessionEnd{
    
    NSDictionary * params = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%ld", [[SessionInstance getInstance] getSessionLength]] forKey:SESSION_LENGTH];
    
    [self queueEventWithName:SESSION_END andValue:1 andParams:params];
}

-(void) queueNewInstall {
    [self queueEventWithName:APP_INSTALL andValue:1 andParams:nil];
}

-(void) queueDeviceInfo:(NSDictionary *) deviceInfo {
    [self queueEventWithName:DEVICE_INFO andValue:1 andParams:deviceInfo];
}

-(void) queueUserInfo:(NSDictionary *)  userInfo {
    [self queueEventWithName:USER_INFO andValue:1 andParams:userInfo];
}


-(void) queueEventWithName:(NSString*) eventName andValue:(NSInteger) eventValue andParams:(NSDictionary *)params{
    @try {
         NSString *eventString = [self eventAsJSON:eventName andValue:eventValue andParameters:params];
        [self.queue addOperation:[[FzEventOperation alloc] initWithEventJSON:eventString]];
    }
    @catch (NSException *exception) {
        NSLog(@"Forkize SDK Error when queue event %@", exception);
    }
}


-(NSString*) eventAsJSON:(NSString*) event  andValue:(NSInteger) eventValue andParameters:(NSDictionary *) parameters //throws JSONException
{
    NSTimeInterval timeInterval = [ForkizeHelper getTimeIntervalSince1970];
    
    NSMutableDictionary * jsonDict = [NSMutableDictionary dictionary];
    [jsonDict setObject:[[DeviceInfo getInstance] getBatteryLevel] forKey:BATTERY_LEVEL];
    
    [jsonDict setObject:event forKey:EVENT_TYPE];
    [jsonDict setObject:[NSString stringWithFormat:@"%ld", (long) eventValue] forKey:EVENT_VALUE];
    
    [jsonDict setObject:[[UserProfile getInstance] getUserId] forKey:USER_ID];
    [jsonDict setObject:[ForkizeConfig getInstance].appId  forKey:APP_ID];
    [jsonDict setObject:[NSString stringWithFormat:@"%ld", (long)timeInterval]  forKey:EVENT_TIME];
    
    if (self.scheduledEvents != nil){
        NSInteger time = [[self.scheduledEvents valueForKey:event] integerValue];
        if (time != 0) {
            [jsonDict setObject:[NSString stringWithFormat:@"%ld", (long)timeInterval - time] forKey:EVENT_DURATION];
            [self.scheduledEvents removeObjectForKey:event];
        }
    }
    
    self.latitude = [[LocationInstance getInstance] latitude];
    self.longitude = [[LocationInstance getInstance] longitude];
    
    if (self.latitude != 0 && self.longitude != 0) {
        [jsonDict setObject:[NSString stringWithFormat:@"%f", self.longitude] forKey:LONGITUDE];
        [jsonDict setObject:[NSString stringWithFormat:@"%f", self.latitude] forKey:LATITUDE];
    }
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NSString *type = @"";
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        //No internet
        type = @"ncon";
    }
    else if (status == ReachableViaWiFi)
    {
        //WiFi
        type = @"wifi";
    }
    else if (status == ReachableViaWWAN)
    {
        //3G
        type = @"mobile";
    }
    
    if (![type isEqualToString:@"ncon"])
         [jsonDict setObject:type forKey:CONNECTION_TYPE];
    
    if (parameters != nil && [parameters count] > 0) {
     
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
//        NSError *parseError = nil;
//        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&parseError];
//
        NSMutableString *paramsString = [[NSMutableString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        if (!error) {
            [jsonDict setObject:paramsString forKey:PARAMS];
        }
    }
    
    for (NSString *key in [self.superPropertiesInternal allKeys]) {
        [jsonDict setObject:[self.superPropertiesInternal objectForKey:key]  forKey:key];
    }
    
    for (NSString *key in [self.superPropertiesOnceInternal allKeys]) {
        [jsonDict setObject:[self.superPropertiesOnceInternal objectForKey:key]  forKey:key];
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

     return resultString;
}

-(void) close{
    [self.queue cancelAllOperations];
    self.queue = nil;
}

@end

