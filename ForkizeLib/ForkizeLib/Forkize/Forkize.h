//
//  Forkize.h
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserProfile;

@protocol IForkize <NSObject>

-(void) authorize:(NSString *)appId andAppKey:(NSString *)appKey;

-(void) identify:(NSString *) userId;

-(void) alias:(NSString*) userId;

-(UserProfile *) getProfile;

-(void) trackEvent:(NSString*) eventName withParams:(NSDictionary*) parameters;

-(void) purchaseWithProductId:(NSString* ) productId  andCurrency:(NSString*) currency andPrice:(double) price andQuantity: (NSInteger) quantity;

-(void) eventDuration:(NSString*) eventName;

-(void) setSuperProperties:(NSDictionary *) properties;

-(void) setSuperPropertiesOnce:(NSDictionary *) properties;

-(BOOL) isNewInstall;

-(void) sessionStart;

-(void) sessionPause;

-(void) sessionResume;

-(void) sessionEnd;

-(void) advanceState:(NSString *) state;

-(void) resetState:(NSString *) state;

-(void) pauseState:(NSString *) state;

-(void) resumeState:(NSString *) state;

-(void)  pause;

-(void)  resume;

-(void)  destroy;  // FZInstance destroy

-(void)  onLowMemory;

-(void)  onTerminate;

@end

@interface Forkize : NSObject<IForkize>

+(id<IForkize>) getInstance;

@end
