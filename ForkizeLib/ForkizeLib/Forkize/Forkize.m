//
//  Forkize.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "Forkize.h"

#import "ForkizeConfig.h"
#import "UserProfile.h"
#import "SessionInstance.h"
#import "DeviceInfo.h"
#import "ForkizeEventManager.h"
#import "LocalStorageManager.h"
#import "LocationInstance.h"
#import "RestClient.h"
#import "ForkizeConfig.h"

@interface Forkize()

@property (nonatomic, assign) NSInteger counter;
@property (nonatomic, assign) BOOL destroyed;
@property (nonatomic, assign) BOOL initialized;
//@property (nonatomic, strong) NSDate *initializedTime;

@property (nonatomic, strong) ForkizeConfig* config;
@property (nonatomic, strong) SessionInstance* sessionInstance;
@property (nonatomic, strong) RestClient* restClient;
@property (nonatomic, strong) LocalStorageManager *localStorage;
@property (nonatomic, strong) UserProfile *userProfile;
@property (nonatomic, strong) ForkizeEventManager *eventManager;

@property (nonatomic, assign) BOOL isRunning;

@property (nonatomic, strong) NSThread *thread;

@end

@implementation Forkize

-(instancetype) init{
    self = [super init];
    
    if (self) {
        self.destroyed = YES;
        self.counter = 0;
        
        self.config          = [ForkizeConfig getInstance];
        self.userProfile     = [UserProfile getInstance];
        self.sessionInstance = [SessionInstance getInstance];
        self.eventManager    = [ForkizeEventManager getInstance];
        self.localStorage    = [LocalStorageManager getInstance];
        self.restClient      = [RestClient getInstance];
                
        self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(runOperations:) object:self];
        
        [[LocationInstance getInstance] setListeners];
        
        NSLog(@"Forkize SDK Forkize constructor called !");
    }
    
    return self;
}

-(void) authorize:(NSString *)appId andAppKey:(NSString *)appKey{
    self.config.appId = appId;
    self.config.appKey = appKey;
}

-(void) trackEvent:(NSString*) eventName  withValue:(NSInteger)eventValue  andParams:(NSDictionary*) parameters{
    [self.eventManager queueEventWithName:eventName andValue:eventValue andParams:parameters];
}

-(void) purchaseWithProductId:(NSString *)productId andCurrency:(NSString *)currency andPrice:(double)price andQuantity:(NSInteger)quantity{
    // FZ::DONE
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          productId, @"product_id",
                          currency,  @"currency",
                          price,     @"price",
                          quantity,  @"quantity",
                          nil];
    
    [self.eventManager queueEventWithName:@"purchase" andValue:0 andParams:dict];
}

-(void) sessionStart{
    [self.sessionInstance start];
    // FZ::TODO
    //[self.eventManager queueSessionStart];
}

-(void) sessionEnd{
    [self.sessionInstance end];
    // FZ::TODO
    //[self.eventManager queueSessionEnd:self.sessionInstance.getSessionLength];
    //[self.sessionInstance dropSessionLength];
}

-(void) eventDurationWithName:(NSString *)eventName{
    [self.eventManager eventDuration:eventName];
}

-(void) setSuperProperties:(NSDictionary *)properties{
    [self.eventManager setSuperProperties:properties];
}

-(void) setSuperPropertiesOnce:(NSDictionary *)properties{
    [self.eventManager setSuperPropertiesOnce:properties];
}

// FZ::TODO::1 MERGE WITH IDENTIFY
-(id<IForkize>) identify:(NSString *) userId{
    
    [[UserProfile getInstance] identify:userId];
    
    self.isRunning = true;
    
    if (self.counter == 1) {
        [UserProfile getInstance].aliasedLevel = 0;
    }
    
    if (self.destroyed) {
        self.destroyed = FALSE;
        self.initialized = FALSE;
        self.counter = 1;
    }
    
    if (!self.initialized) {
        
        @try {
            
            self.initialized = true;
            
        //  self.initializedTime = [NSDate date];
            
            // FZ::TODO sessionStart
            [self sessionStart];
            //[self.sessionInstance generateNewSessionInterval];
            //[self.eventManager queueSessionStart];
            
            if ([self.userProfile isNewInstall]) {
                [self.eventManager queueNewInstall];
            }
            
            // FZ::TODO
            //[self.eventManager queueDeviceInfo:[[DeviceInfo getInstance] getDeviceInfo]];
            // ** FZ::TODO seems getUserInfo returns the changelog
            
            // FZ::TODO CHANGE WITH CHANGELOG
            [self.eventManager queueUserInfo:[self.userProfile getUserInfo]];
        }
        
        @catch (NSException *exception) {
            NSLog(@"Forkize SDK Failed to initialize %@", exception);
        }
    }
    
    ++self.counter;

    
    if (self.thread != nil)
        [self.thread start];
    
    return self;
}

-(void)runOperations:(id<IForkize>) forkize{
    while (self.isRunning) {
        @try {
            [self.userProfile printChangeLog];
            [self.restClient flush];
            [NSThread sleepForTimeInterval:[[ForkizeConfig getInstance] TIME_AFTER_FLUSH]];
        }
        @catch (NSException *exception) {
             NSLog(@"Forkize SDK Something went wrong in MainRunnable %@", exception);
        }
    }
}

-(void)  onPause{
    @try {
        --self.counter;
        [self.localStorage flushToDatabase];
        [self.userProfile flushToDatabase];
        
        [self.sessionInstance pause];
        
        NSLog(@"Forkize SDK On Pause");
        
    } @catch (NSException* exception) {
        NSLog(@"Forkize SDK Exception thrown onPause %@", exception);
    }
}

-(void)  onResume{
    @try {
        ++self.counter;
        
        [self.userProfile restoreFromDatabase];
        
        
        [self.sessionInstance resume];
    } @catch (NSException *exception) {
        NSLog(@"Forkize SDK Exception thrown onResume %@", exception);
    }
}

-(void)  onDestroy{
    @try {
        NSLog(@"Forkize SDK counter in time of destroy %ld" , (long)self.counter);
        
        if (--self.counter == 0) {
            @try {
                [self shutDown];
                NSLog(@"Forkize SDK Last destroy");
            } @catch (NSException* e) {
                NSLog(@"Forkize SDK _onDestroy %@", e);
            }
        }
        
        if (self.counter == 1) {
            [self.sessionInstance end];
            [self.localStorage flushToDatabase];
            [self.userProfile flushToDatabase];
        }
        
        NSLog(@"Forkize SDK onDestroy!");

    } @catch (NSException *e) {
        NSLog(@"Forkize SDK Exception thrown onDestroy %@", e);
    }
}

-(void)  onLowMemory{
    @try {
        if (self.localStorage != nil){
            [self.localStorage flushToDatabase];
            [self.userProfile flushToDatabase];
            
        }
    } @catch (NSException* e) {
        NSLog(@"Forkize SDK Exception thrown onLowMemory %@", e);
    }
}

-(void) onTerminate{
    [self shutDown];
}

-(void) shutDown //@throws InterruptedException
{
    if (!self.destroyed) {
        NSLog(@"Forkize SDK Shutting down the SDK ...");
        
  //      self.initializedTime = nil;
        
        [self.restClient close];
        self.restClient = nil;
        
        [self.eventManager close];
        self.eventManager = nil;
        
        [self.localStorage close];
        self.localStorage = nil;
        
        self.isRunning = FALSE;
        self.destroyed = TRUE;
        
        // FZ::DONE what about session Instance ?
        
        
        NSLog(@"Forkize SDK SDK is shot down!");
    }
}


@end
