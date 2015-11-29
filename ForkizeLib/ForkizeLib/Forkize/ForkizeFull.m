//
//  ForkizeFull.m
//  ForkizeLib
//
//  Created by Artak1 on 11/25/15.
//  Copyright © 2015 Artak. All rights reserved.
//

#import "ForkizeFull.h"

#import "ForkizeConfig.h"
#import "UserProfileInternal.h"
#import "UserProfile.h"

#import "ForkizeEventManager.h"
#import "LocationInstance.h"
#import "RestClient.h"
#import "ForkizeHelper.h"


NSString *const FORKIZE_INSTALL_TIME = @"$forkize_install_time";


@interface ForkizeFull()

@property (nonatomic, assign) BOOL destroyed;
@property (nonatomic, assign) BOOL initialized;

@property (nonatomic, strong) RestClient* restClient;
@property (nonatomic, strong) UserProfileInternal *userProfile;
@property (nonatomic, strong) ForkizeEventManager *eventManager;

@property (nonatomic, assign) BOOL isRunning;

@property (nonatomic, strong) NSThread *thread;

@end

@implementation ForkizeFull

-(instancetype) init{
    self = [super init];
    
    if (self) {
        self.destroyed = YES;
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
    
    if (self.destroyed) {
        self.initialized = NO;
        self.destroyed = NO;
        
        self.userProfile   = [UserProfileInternal getInstance];
        self.eventManager  = [ForkizeEventManager getInstance];
        self.restClient    = [RestClient getInstance];
        
        self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(runOperations:) object:self];
       [[LocationInstance getInstance] setListeners];
    }
    
}

-(void) identify:(NSString *) userId{
    
    if (self.destroyed) {
        //FZ::Point
        @throw [NSException  exceptionWithName:@"Forkize" reason:@"authorize must be called before identify" userInfo:nil];
    }
    if (!self.initialized) {
        
        @try {
            self.initialized = YES;
            self.destroyed = NO;
            
            [self.userProfile identify:userId];
            [self sessionStart];
            
            self.isRunning = true;
            
            if ([self isNewInstall]) {
                // FZ::POINT just setting new install on device storage
                NSString *installTime = [[NSUserDefaults standardUserDefaults] valueForKey:FORKIZE_INSTALL_TIME];
                installTime = [NSString stringWithFormat:@"%ld", (long)[ForkizeHelper getTimeIntervalSince1970]];
                [[NSUserDefaults  standardUserDefaults] setObject:installTime forKey:FORKIZE_INSTALL_TIME];
            }
        }
        
        @catch (NSException *exception) {
            NSLog(@"Forkize SDK Failed to identify %@", exception);
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

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          productId, @"$product_id",
                          currency,  @"$currency",
                          price,     @"$price",
                          quantity,  @"$quantity",
                          nil];
    
    [self.eventManager queueEventWithName:@"$purchase" andParams:dict];
}

-(BOOL) isNewInstall{
    NSString *installTime = [[NSUserDefaults standardUserDefaults] valueForKey:FORKIZE_INSTALL_TIME];
    
    return [ForkizeHelper isNilOrEmpty:installTime];
}

-(void) sessionStart{
    [self.userProfile start];
}

-(void) sessionEnd{
    [self.userProfile end];
}

-(void) sessionPause{
    [self.userProfile pause];
}

-(void) sessionResume{
    [self.userProfile resume];
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
        [self.eventManager flushCacheToDatabase];
        
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
            
            [self.eventManager flushCacheToDatabase];
            
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
        
        [self.eventManager flushCacheToDatabase];
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
        // ** we should close user profile befor eventmanager
        // ** userprofile end queues sessionEnd event
        [self.userProfile end];
        
        [self.eventManager close];
        self.eventManager = nil;
        
        self.isRunning = NO;
        self.initialized = NO;
        self.destroyed = YES;
        

        
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
