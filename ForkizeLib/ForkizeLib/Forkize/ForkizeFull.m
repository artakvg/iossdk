//
//  ForkizeFull.m
//  ForkizeLib
//
//  Created by Artak1 on 11/25/15.
//  Copyright © 2015 Artak. All rights reserved.
//

#import "ForkizeFull.h"

#import "ForkizeConfig.h"
#import "UserProfile.h"
#import "ForkizeEventManager.h"
#import "LocalStorageManager.h"
#import "LocationInstance.h"
#import "RestClient.h"

@interface ForkizeFull()

@property (nonatomic, assign) BOOL destroyed;
@property (nonatomic, assign) BOOL initialized;

@property (nonatomic, strong) RestClient* restClient;
@property (nonatomic, strong) LocalStorageManager *localStorage;
@property (nonatomic, strong) UserProfile *userProfile;
@property (nonatomic, strong) ForkizeEventManager *eventManager;

@property (nonatomic, assign) BOOL isRunning;

@property (nonatomic, strong) NSThread *thread;

@end

@implementation ForkizeFull

-(instancetype) init{
    self = [super init];
    
    if (self) {
        self.destroyed = YES;
        self.initialized = NO;
        
        self.userProfile     = [UserProfile getInstance];
        self.eventManager    = [ForkizeEventManager getInstance];
        self.localStorage    = [LocalStorageManager getInstance];
        self.restClient      = [RestClient getInstance];
        
        self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(runOperations:) object:self];
        
        [[LocationInstance getInstance] setListeners];
        
        NSLog(@"Forkize SDK Forkize constructor called !");
    }
    
    return self;
}

-(void)runOperations:(id<IForkize>) forkize{
    while (self.isRunning) {
        @try {
            NSLog(@"Forkize SDK %@", [self.userProfile getChangeLog]); // FZ::TODO remove this in production version
            [self.restClient flush];
            [NSThread sleepForTimeInterval:[[ForkizeConfig getInstance] TIME_AFTER_FLUSH]];
        }
        @catch (NSException *exception) {
            NSLog(@"Forkize SDK Something went wrong in MainRunnable %@", exception);
        }
    }
}


-(void) authorize:(NSString *)appId andAppKey:(NSString *)appKey{
    ForkizeConfig *config = [ForkizeConfig getInstance];
    config.appId = appId;
    config.appKey = appKey;
}

// FZ::TODO::1 MERGE WITH IDENTIFY
-(void) identify:(NSString *) userId{
    
    [self.userProfile identify:userId];
    
    self.isRunning = true;
    
    if (!self.initialized) {
        
        @try {
            
            self.initialized = YES;
            self.destroyed = NO;
            
            [self sessionStart];
            
            if ([self.userProfile isNewInstall]) {
                [self.eventManager queueNewInstall];
                
                //[self.eventManager queueDeviceInfo];
                
                // [self.eventManager queueUserInfo];
            }
        }
        
        @catch (NSException *exception) {
            NSLog(@"Forkize SDK Failed to initialize %@", exception);
        }
    }
    
    if (self.thread != nil)
        [self.thread start];
}

-(void) alias:(NSString*) userId{
    [self.userProfile alias:userId];
}

-(void) trackEvent:(NSString*) eventName withParams:(NSDictionary*) parameters{
    [self.eventManager queueEventWithName:eventName andParams:parameters];
}

-(void) purchaseWithProductId:(NSString *)productId andCurrency:(NSString *)currency andPrice:(double)price andQuantity:(NSInteger)quantity{
    // FZ::DONE
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          productId, @"product_id",
                          currency,  @"currency",
                          price,     @"price",
                          quantity,  @"quantity",
                          nil];
    
    [self.eventManager queueEventWithName:@"purchase" andParams:dict];
}

-(void) sessionStart{
    [self.userProfile start];
}

-(void) sessionEnd{
    [self.userProfile end];
}

-(void) eventDuration:(NSString *)eventName{
    [self.eventManager eventDuration:eventName];
}

-(void) setSuperProperties:(NSDictionary *)properties{
    [self.eventManager setSuperProperties:properties];
}

-(void) setSuperPropertiesOnce:(NSDictionary *)properties{
    [self.eventManager setSuperPropertiesOnce:properties];
}

-(void)  pause{
    @try {
        [self.localStorage flushToDatabase];
        
        [self.userProfile pause];
        
        NSLog(@"Forkize SDK On Pause");
        
    } @catch (NSException* exception) {
        NSLog(@"Forkize SDK Exception thrown onPause %@", exception);
    }
}

-(void)  resume{
    @try {
        
        [self.userProfile resume];
        
    } @catch (NSException *exception) {
        NSLog(@"Forkize SDK Exception thrown onResume %@", exception);
    }
}

-(void)  destroy{
    @try {
        
        if (!self.destroyed) {
            [self.userProfile end];
            
            [self.localStorage flushToDatabase];
            
            self.destroyed = YES;
            
            [self shutDown];
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
        [self.restClient close];
        self.restClient = nil;
        
        [self.eventManager close];
        self.eventManager = nil;
        
        [self.localStorage close];
        self.localStorage = nil;
        
        self.isRunning = NO;
        self.initialized = NO;
        self.destroyed = YES;
        
        // FZ::DONE what about session Instance ?
        
        NSLog(@"Forkize SDK SDK is shot down!");
    }
}

-(void) advanceState:(NSString *) state{
    [self.eventManager advanceState:state];
}

-(void) resetState:(NSString *) state{
    [self.eventManager resetState:state];
}

-(void) pauseState:(NSString *) state{
    [self.eventManager pauseState:state];
}

-(void) resumeState:(NSString *) state{
    [self.eventManager resumeState:state];
}

@end
