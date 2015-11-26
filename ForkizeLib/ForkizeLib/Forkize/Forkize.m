//
//  Forkize.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "Forkize.h"

#import <UIKit/UIKit.h>

#import "ForkizeFull.h"
#import "ForkizeEmpty.h"

@implementation Forkize

+(id<IForkize>) getInstance{
    static id<IForkize> sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSInteger version = [[UIDevice currentDevice].systemVersion floatValue];
        if (version >= 8.0) {
            sharedInstance = [[ForkizeFull alloc] init];
        } else {
            sharedInstance = [[ForkizeEmpty alloc] init];
        }
        
    });
    return sharedInstance;
}

-(void) authorize:(NSString *)appId andAppKey:(NSString *)appKey{
    [[Forkize getInstance] authorize:appId andAppKey:appKey];
}

-(void) identify:(NSString *) userId{
    [[Forkize getInstance]  identify:userId];
}

-(void) alias:(NSString*) userId{
    [[Forkize getInstance] alias:userId];
}

-(void) trackEvent:(NSString*) eventName withParams:(NSDictionary*) parameters{
    [[Forkize getInstance]  trackEvent:eventName withParams:parameters];
}

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

-(void) sessionStart{
    [[Forkize getInstance]  sessionStart];
}

-(void) sessionEnd{
    [[Forkize getInstance]  sessionEnd];
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

@end
