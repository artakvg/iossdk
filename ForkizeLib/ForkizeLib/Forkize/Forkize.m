//
//  Forkize.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "Forkize.h"
#import "ForkizeFull.h"
#import "ForkizeEmpty.h"
#import <UIKit/UIKit.h>

@implementation Forkize

// FZ::POINT maybe we can merge it with authorize

+(id<IForkize>) getInstance{
    static id<IForkize> sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // FZ::POINT systemVersion
        NSInteger version = [[UIDevice currentDevice].systemVersion floatValue];
        if (version >= 8.0) {
            sharedInstance = [[ForkizeFull alloc] init];
        } else {
            sharedInstance = [[ForkizeEmpty alloc] init];
        }
    });
    return sharedInstance;
}

// FZ::POINT maybe we can merge it with getInstance
-(void) authorize:(NSString *)appId andAppKey:(NSString *)appKey{
    [[Forkize getInstance] authorize:appId andAppKey:appKey];
}

-(void) identify:(NSString *) userId{
    [[Forkize getInstance]  identify:userId];
}

-(void) alias:(NSString*) userId{
    [[Forkize getInstance] alias:userId];
}

-(UserProfile *) getProfile{
    return [[Forkize getInstance] getProfile];
}

-(void) trackEvent:(NSString*) eventName withParams:(NSDictionary*) parameters{
    [[Forkize getInstance]  trackEvent:eventName withParams:parameters];
}

// FZ::TODO quite long for a function name
-(void) purchaseWithProductId:(NSString* ) productId  andCurrency:(NSString*) currency andPrice:(double) price andQuantity: (NSInteger) quantity{
    [[Forkize getInstance]  purchaseWithProductId:productId andCurrency:currency andPrice:price andQuantity:quantity];
}

-(void) eventDuration:(NSString*) eventName{
    [[Forkize getInstance]  eventDuration:eventName];
}

-(void) setSuperProperties:(NSDictionary *) properties{
    [[Forkize getInstance]  setSuperProperties:properties];
}

-(void) setSuperPropertiesOnce:(NSDictionary *) properties{
    [[Forkize getInstance]  setSuperPropertiesOnce:properties];
}

-(BOOL) isNewInstall{
    return [[Forkize getInstance] isNewInstall];
}

-(void) sessionStart{
    [[Forkize getInstance]  sessionStart];
}

-(void) sessionPause{
    [[Forkize getInstance]  sessionPause];
}

-(void) sessionResume{
    [[Forkize getInstance]  sessionResume];
}

-(void) sessionEnd{
    [[Forkize getInstance]  sessionEnd];
}


-(void) advanceState:(NSString *) state{
    [[Forkize getInstance]  advanceState:state];
}

-(void) resetState:(NSString *) state{
    [[Forkize getInstance]  resetState:state];
}

-(void) pauseState:(NSString *) state{
    [[Forkize getInstance]  pauseState:state];
}

-(void) resumeState:(NSString *)state{
    [[Forkize getInstance]  resumeState:state];
}

-(void)  pause{
    [[Forkize getInstance]  pause];
}

-(void)  resume{
    [[Forkize getInstance]  resume];
}

-(void)  destroy{
    [[Forkize getInstance]  destroy];
}

-(void)  onLowMemory{
    [[Forkize getInstance]  onLowMemory];
}

-(void)  onTerminate{
    [[Forkize getInstance] onTerminate];
}

@end
